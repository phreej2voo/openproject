# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
# ++

class WorkPackages::RemindersController < ApplicationController
  include OpTurbo::ComponentStream
  layout false
  before_action :find_work_package
  before_action :build_or_find_reminder, only: %i[modal_body create]
  before_action :find_reminder, only: %i[update destroy]

  before_action :authorize

  def modal_body
    render modal_component_class.new(
      remindable: @work_package,
      reminder: @reminder
    )
  end

  def create
    service_result = Reminders::CreateService.new(user: current_user)
                                             .call(reminder_params)

    if service_result.success?
      render_success_flash_message_via_turbo_stream(message: I18n.t("work_package.reminders.success_creation_message"))
      respond_with_turbo_streams
    else
      prepare_errors_from_result(service_result)

      replace_via_turbo_stream(
        component: modal_component_class.new(
          remindable: @work_package,
          reminder: @reminder,
          errors: @errors
        )
      )

      respond_with_turbo_streams(status: :unprocessable_entity)
    end
  end

  def update
    service_result = Reminders::UpdateService.new(user: current_user,
                                                  model: @reminder)
                                             .call(reminder_params)

    if service_result.success?
      render_success_flash_message_via_turbo_stream(message: I18n.t("work_package.reminders.success_update_message"))
      respond_with_turbo_streams
    else
      prepare_errors_from_result(service_result)

      replace_via_turbo_stream(
        component: modal_component_class.new(
          remindable: @work_package,
          reminder: @reminder,
          errors: @errors
        )
      )

      respond_with_turbo_streams(status: :unprocessable_entity)
    end
  end

  def destroy
    service_result = Reminders::DeleteService.new(user: current_user,
                                                  model: @reminder)
                                             .call

    if service_result.success?
      render_success_flash_message_via_turbo_stream(message: I18n.t("work_package.reminders.success_deletion_message"))
      respond_with_turbo_streams
    else
      render_error_flash_message_via_turbo_stream(message: service_result.errors.full_messages)
      respond_with_turbo_streams(status: :unprocessable_entity)
    end
  end

  private

  def modal_component_class
    WorkPackages::Reminder::ModalBodyComponent
  end

  def find_work_package
    @work_package = WorkPackage.visible.find(params[:work_package_id])
  end

  # At the form level, we split the date and time into two form fields.
  # In order to be a bit more informative of which field is causing
  # the remind_at attribute to be in the past/invalid, we need to
  # remap the error attribute to the appropriate field.
  def prepare_errors_from_result(service_result)
    # We set the reminder here for "create" case
    # as the record comes from the service.
    @reminder = service_result.result
    @errors = service_result.errors

    case @errors.find { |error| error.attribute == :remind_at }&.type
    when :blank
      handle_blank_error
    when :datetime_must_be_in_future
      handle_future_error
    end

    @errors.delete(:remind_at)
  end

  def handle_blank_error
    @errors.add(:remind_at_date, :blank) if remind_at_date.blank?
    @errors.add(:remind_at_time, :blank) if remind_at_time.blank?
  end

  def handle_future_error
    @errors.add(:remind_at_date, :datetime_must_be_in_future) if @reminder.remind_at.to_date < today_in_user_time_zone
    @errors.add(:remind_at_time, :datetime_must_be_in_future) if @reminder.remind_at < now_in_user_time_zone
  end

  def now_in_user_time_zone
    @now_in_user_time_zone ||= Time.current
                                   .in_time_zone(User.current.time_zone)
  end

  def today_in_user_time_zone
    @today_in_user_time_zone ||= now_in_user_time_zone.to_date
  end

  # We assume for now that there is only one reminder per work package
  def build_or_find_reminder
    @reminder = @work_package.reminders
                             .upcoming_and_visible_to(User.current)
                             .last || @work_package.reminders.build
  end

  def find_reminder
    @reminder = @work_package.reminders
                             .upcoming_and_visible_to(User.current)
                             .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error_flash_message_via_turbo_stream(message: I18n.t(:error_reminder_not_found))
    respond_with_turbo_streams(status: :not_found)
    false
  end

  def reminder_params
    params.require(:reminder)
          .permit(%i[remind_at_date remind_at_time note])
          .tap do |initial_params|
      date = initial_params.delete(:remind_at_date)
      time = initial_params.delete(:remind_at_time)

      initial_params[:remind_at] = build_remind_at_from_params(date, time)
      initial_params[:remindable] = @work_package
      initial_params[:creator] = User.current
    end
  end

  def build_remind_at_from_params(remind_at_date, remind_at_time)
    if remind_at_date.present? && remind_at_time.present?
      DateTime.parse("#{remind_at_date} #{User.current.time_zone.parse(remind_at_time)}")
    end
  end

  def remind_at_date
    params[:reminder][:remind_at_date]
  end

  def remind_at_time
    params[:reminder][:remind_at_time]
  end
end
