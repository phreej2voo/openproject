#-- copyright
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
#++

require "spec_helper"

RSpec.describe RecurringMeetings::UpdateService, "integration", type: :model do
  shared_let(:project) { create(:project, enabled_module_names: %i[meetings]) }
  shared_let(:user) do
    create(:user, member_with_permissions: { project => %i(view_meetings edit_meetings) })
  end
  shared_let(:series, refind: true) do
    create(:recurring_meeting,
           project:,
           start_time: Time.zone.today + 10.hours,
           frequency: "daily",
           interval: 1,
           end_after: "specific_date",
           end_date: 1.month.from_now)
  end

  let(:instance) { described_class.new(model: series, user:) }
  let(:params) { {} }

  let(:service_result) { instance.call(**params) }
  let(:updated_meeting) { service_result.result }

  context "with a cancelled meeting for tomorrow" do
    let!(:scheduled_meeting) do
      create(:scheduled_meeting,
             :cancelled,
             recurring_meeting: series,
             start_time: Time.zone.today + 1.day + 10.hours)
    end

    context "when updating the start_date to the same time" do
      let(:params) do
        { start_date: Time.zone.today + 1.day }
      end

      it "keeps that cancelled occurrence" do
        expect(service_result).to be_success
        expect(updated_meeting.start_time).to eq(Time.zone.today + 1.day + 10.hours)

        expect { scheduled_meeting.reload }.not_to raise_error
      end
    end

    context "when updating the start_date to further in the future" do
      let(:params) do
        { start_date: Time.zone.today + 2.days }
      end

      it "deletes that cancelled occurrence" do
        expect(service_result).to be_success
        expect(updated_meeting.start_time).to eq(Time.zone.today + 2.days + 10.hours)

        expect { scheduled_meeting.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "rescheduling job" do
    context "when updating the title" do
      let(:params) do
        { title: "New title" }
      end

      it "does not reschedule" do
        expect { service_result }.not_to have_enqueued_job(RecurringMeetings::InitNextOccurrenceJob)
        expect(service_result).to be_success
      end
    end

    context "when updating the frequency and start_time" do
      let(:params) do
        { start_time: Time.zone.today + 2.days + 11.hours }
      end

      before do
        ActiveJob::Base.disable_test_adapter
        RecurringMeetings::InitNextOccurrenceJob
          .set(wait_until: Time.zone.today + 1.day + 10.hours)
          .perform_later(series)
      end

      it "reschedules and enqueues the next job" do
        job = GoodJob::Job.find_by(job_class: "RecurringMeetings::InitNextOccurrenceJob")
        expect(job.scheduled_at).to eq Time.zone.today + 1.day + 10.hours
        expect(service_result).to be_success
        expect { job.reload }.to raise_error(ActiveRecord::RecordNotFound)

        new_job = GoodJob::Job.find_by(job_class: "RecurringMeetings::InitNextOccurrenceJob")
        expect(new_job.scheduled_at).to eq Time.zone.today + 2.days + 11.hours

        expect(series.upcoming_instantiated_meetings.count).to eq 1
      end
    end
  end
end
