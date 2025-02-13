# frozen_string_literal: true

class RecurringMeetingsController < ApplicationController
  include Layout
  include PaginationHelper
  include OpTurbo::ComponentStream
  include OpTurbo::FlashStreamHelper
  include OpTurbo::DialogStreamHelper

  before_action :find_meeting,
                only: %i[show update details_dialog delete_dialog destroy edit init
                         delete_scheduled_dialog destroy_scheduled template_completed download_ics notify end_series
                         end_series_dialog]
  before_action :find_optional_project,
                only: %i[index show new create update details_dialog delete_dialog destroy edit delete_scheduled_dialog
                         destroy_scheduled notify]
  before_action :authorize_global, only: %i[index new create]
  before_action :authorize, except: %i[index new create]
  before_action :get_scheduled_meeting, only: %i[delete_scheduled_dialog destroy_scheduled]

  before_action :set_direction, only: %i[show]
  before_action :convert_params, only: %i[create update]
  before_action :check_template_completable, only: %i[template_completed]
  before_action :build_meeting_limits, only: %i[show]

  menu_item :meetings

  def index
    results =
      if @project
        RecurringMeeting.visible.where(project_id: @project.id)
      else
        RecurringMeeting.visible
      end

    @recurring_meetings = show_more_pagination(results)

    respond_to do |format|
      format.html do
        render :index, locals: { menu_name: project_or_global_menu }
      end
    end
  end

  def new
    @recurring_meeting = RecurringMeeting.new(project: @project)
  end

  def show # rubocop:disable Metrics/AbcSize
    if @direction == "past"
      @meetings = @recurring_meeting.scheduled_instances(upcoming: false).limit(@count)
    else
      @meetings, @planned_meetings = upcoming_meetings(count: @count)
    end

    respond_to do |format|
      format.html do
        render :show, locals: { menu_name: project_or_global_menu }
      end
    end
  end

  def init
    call = ::RecurringMeetings::InitOccurrenceService
      .new(user: current_user, recurring_meeting: @recurring_meeting)
      .call(start_time: DateTime.iso8601(params[:start_time]))

    if call.success?
      redirect_to project_meeting_path(call.result.project, call.result), status: :see_other
    else
      flash[:error] = call.message
      redirect_to action: :show, id: @recurring_meeting
    end
  end

  def details_dialog
    respond_with_dialog Meetings::Index::DialogComponent.new(
      meeting: @recurring_meeting,
      project: @recurring_meeting.project
    )
  end

  def create # rubocop:disable Metrics/AbcSize
    call = ::RecurringMeetings::CreateService
      .new(user: current_user)
      .call(@converted_params)

    if call.success?
      flash[:notice] = I18n.t(:notice_successful_create).html_safe
      redirect_to polymorphic_path([@project, :meeting], { id: call.result.template.id }),
                  status: :see_other
    else
      respond_to do |format|
        format.turbo_stream do
          update_via_turbo_stream(
            component: Meetings::Index::FormComponent.new(
              meeting: call.result,
              project: @project,
              copy_from: @copy_from
            ),
            status: :bad_request
          )

          respond_with_turbo_streams
        end
      end
    end
  end

  def edit
    redirect_to controller: "meetings", action: "show", id: @recurring_meeting.template, status: :see_other
  end

  def update
    call = ::RecurringMeetings::UpdateService
      .new(model: @recurring_meeting, user: current_user)
      .call(@converted_params)

    if call.success?
      redirect_back(fallback_location: recurring_meeting_path(call.result), status: :see_other, turbo: false)
    else
      respond_to do |format|
        format.turbo_stream do
          update_via_turbo_stream(
            component: Meetings::Index::FormComponent.new(
              meeting: call.result,
              project: @project
            ),
            status: :bad_request
          )

          respond_with_turbo_streams
        end
      end
    end
  end

  def end_series_dialog
    respond_with_dialog RecurringMeetings::EndSeriesDialogComponent.new(@recurring_meeting)
  end

  def end_series
    call = ::RecurringMeetings::UpdateService
      .new(model: @recurring_meeting, user: current_user)
      .call(end_after: "specific_date", end_date: Time.zone.today)

    if call.success?
      @recurring_meeting.scheduled_meetings.upcoming.destroy_all
    else
      flash[:error] = call.message
    end
    redirect_to action: :show
  end

  def delete_dialog
    respond_with_dialog RecurringMeetings::DeleteDialogComponent.new(
      recurring_meeting: @recurring_meeting,
      project: @project
    )
  end

  def destroy
    if @recurring_meeting.destroy
      flash[:notice] = I18n.t(:notice_successful_delete)
    else
      flash[:error] = I18n.t(:error_failed_to_delete_entry)
    end

    respond_to do |format|
      format.html do
        redirect_to polymorphic_path([@project, :meetings])
      end
    end
  end

  def template_completed
    call = ::RecurringMeetings::InitOccurrenceService
      .new(user: current_user, recurring_meeting: @recurring_meeting)
      .call(start_time: @first_occurrence)

    if call.success?
      init_next_occurrence_job(@first_occurrence)
      deliver_invitation_mails

      flash[:success] = I18n.t("recurring_meeting.occurrence.first_created")
    else
      flash[:error] = call.message
    end

    redirect_to action: :show, id: @recurring_meeting, status: :see_other
  end

  def delete_scheduled_dialog
    respond_with_dialog RecurringMeetings::DeleteScheduledDialogComponent.new(
      scheduled_meeting: @scheduled_meeting,
      project: @project
    )
  end

  def destroy_scheduled
    if @scheduled_meeting.update(cancelled: true)
      flash[:notice] = I18n.t(:notice_successful_cancel)
    else
      flash[:error] = I18n.t(:error_failed_to_delete_entry)
    end

    redirect_to polymorphic_path([@project, @recurring_meeting]), status: :see_other
  end

  def download_ics # rubocop:disable Metrics/AbcSize
    service = ::RecurringMeetings::ICalService.new(user: current_user, series: @recurring_meeting)
    filename, result =
      if params[:occurrence_id].present?
        occurrence = @recurring_meeting.meetings.find_by(id: params[:occurrence_id])
        ["#{@recurring_meeting.title} - #{occurrence.start_time.to_date.iso8601}",
         service.generate_occurrence(occurrence)]
      else
        [@recurring_meeting.title, service.generate_series]
      end

    result
      .on_failure { |call| render_500(message: call.message) }
      .on_success do |call|
      send_data call.result, filename: filename_for_content_disposition("#{filename}.ics")
    end
  end

  def notify
    deliver_invitation_mails
    flash[:notice] = I18n.t(:notice_successful_notification)
    redirect_to action: :show
  end

  private

  def init_next_occurrence_job(from_time)
    # Now we can schedule the job to create the next occurrence
    next_occurrence = @recurring_meeting.next_occurrence(from_time:)&.to_time
    return if next_occurrence.nil?

    ::RecurringMeetings::InitNextOccurrenceJob
      .set(wait_until: from_time)
      .perform_later(@recurring_meeting, next_occurrence)
  end

  def deliver_invitation_mails
    @recurring_meeting
      .template
      .participants
      .invited
      .find_each do |participant|
      MeetingSeriesMailer.template_completed(
        @recurring_meeting,
        participant.user,
        User.current
      ).deliver_later
    end
  end

  def upcoming_meetings(count:)
    opened = @recurring_meeting
      .upcoming_instantiated_meetings
      .index_by(&:start_time)

    cancelled = @recurring_meeting
      .upcoming_cancelled_meetings
      .index_by(&:start_time)

    # Planned meetings consist of scheduled occurrences and cancelled meetings
    # Open meetings are removed from the scheduled occurrences as they are displayed separately
    planned = @recurring_meeting
      .scheduled_occurrences(limit: count + opened.count)
      .reject { |start_time| opened.include?(start_time) }
      .map { |start_time| cancelled[start_time] || scheduled_meeting(start_time) }
      .first(count)

    [opened.values.sort_by(&:start_time), planned]
  end

  def set_direction
    @direction = params[:direction]
  end

  def build_meeting_limits
    @max_count =
      if @direction == "past"
        @recurring_meeting.scheduled_instances(upcoming: false).count
      elsif @recurring_meeting.will_end?
        open = @recurring_meeting.upcoming_instantiated_meetings
        @recurring_meeting.remaining_occurrences.count - open.count
      end

    @count = [show_more_limit_param, @max_count].compact.min
  end

  def scheduled_meeting(start_time)
    ScheduledMeeting.new(start_time:, recurring_meeting: @recurring_meeting)
  end

  def get_scheduled_meeting
    @scheduled_meeting = @recurring_meeting.scheduled_meetings.find_or_initialize_by(start_time: params[:start_time])

    render_400 unless @scheduled_meeting.meeting_id.nil?
  end

  def find_optional_project
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_meeting
    @recurring_meeting = RecurringMeeting.visible.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def convert_params
    # We do some preprocessing of `meeting_params` that we will store in this
    # instance variable.
    @converted_params = recurring_meeting_params.to_h

    @converted_params[:project] = @project
    @converted_params[:duration] = @converted_params[:duration].to_hours if @converted_params[:duration].present?
  end

  def recurring_meeting_params
    params
      .require(:meeting)
      .permit(:title, :location, :start_time_hour, :duration, :start_date,
              :interval, :frequency, :end_after, :end_date, :iterations)
  end

  def find_copy_from_meeting
    copied_from_meeting_id = params[:copied_from_meeting_id] || params[:meeting][:copied_from_meeting_id]
    return unless copied_from_meeting_id

    @copy_from = Meeting.visible.find(copied_from_meeting_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def structured_meeting_params
    if params[:structured_meeting].present?
      params
        .require(:structured_meeting)
    end
  end

  def check_template_completable
    @first_occurrence = @recurring_meeting.next_occurrence&.to_time
    if @first_occurrence.nil?
      render_400(message: I18n.t("recurring_meeting.occurrence.error_no_next"))
      return
    end

    is_scheduled = @recurring_meeting
      .scheduled_meetings
      .where(start_time: @first_occurrence)
      .where.not(meeting_id: nil)
      .exists?

    if is_scheduled
      flash[:info] = I18n.t("recurring_meeting.occurrence.first_already_exists")
      redirect_to action: :show, status: :see_other
    end
  end
end
