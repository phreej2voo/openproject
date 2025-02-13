# frozen_string_literal: true

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

require "rails_helper"

RSpec.describe RecurringMeetings::RowComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:project) { build_stubbed(:project) }
  let(:table) do
    instance_double(RecurringMeetings::TableComponent,
                    columns: [], grid_class: "test", has_actions?: true, current_project:)
  end
  let(:recurring_meeting) { build_stubbed(:recurring_meeting, project:) }
  let(:current_project) { nil }
  let(:user) { build_stubbed(:user) }

  subject do
    render_inline(described_class.new(row: scheduled_meeting, table:))
    page
  end

  before do
    login_as(user)
  end

  describe "actions" do
    context "with project delete meetings permissions" do
      before do
        mock_permissions_for(user) do |mock|
          mock.allow_in_project(:delete_meetings, project:)
        end
      end

      context "with a scheduled meeting" do
        let(:scheduled_meeting) { build_stubbed(:scheduled_meeting, :scheduled, recurring_meeting:) }

        context "without a current project" do
          it "shows cancel menu item" do
            expect(subject).to have_link "Cancel this occurrence",
                                         href: delete_scheduled_dialog_recurring_meeting_path(
                                           recurring_meeting, start_time: scheduled_meeting.start_time.iso8601
                                         )
          end
        end

        context "with a current project" do
          let(:current_project) { project }

          it "shows cancel menu item" do
            expect(subject).to have_link "Cancel this occurrence",
                                         href: delete_scheduled_dialog_project_recurring_meeting_path(
                                           project, recurring_meeting, start_time: scheduled_meeting.start_time.iso8601
                                         )
          end
        end
      end

      context "with an instantiated meeting" do
        let(:scheduled_meeting) { build_stubbed(:scheduled_meeting, recurring_meeting:, meeting:) }
        let(:meeting) { build_stubbed(:meeting) }

        context "without a current project" do
          it "shows cancel menu item" do
            expect(subject).to have_link "Cancel this occurrence",
                                         href: delete_dialog_meeting_path(scheduled_meeting.meeting)
          end
        end

        context "with a current project" do
          let(:current_project) { project }

          it "shows cancel menu item" do
            expect(subject).to have_link "Cancel this occurrence",
                                         href: delete_dialog_project_meeting_path(project, scheduled_meeting.meeting)
          end
        end
      end
    end
  end
end
