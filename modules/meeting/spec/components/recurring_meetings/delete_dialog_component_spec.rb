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

RSpec.describe RecurringMeetings::DeleteDialogComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:project) { build_stubbed(:project) }
  let(:recurring_meeting) { build_stubbed(:recurring_meeting, project:, end_after: :iterations, iterations: 6) }
  let(:meeting) { build_stubbed(:structured_meeting_template, recurring_meeting:) }
  let(:user) { build_stubbed(:user) }

  subject do
    render_inline(described_class.new(recurring_meeting:, project:))
    page
  end

  before do
    login_as(user)
  end

  describe "dialog form" do
    context "without a current project" do
      let(:project) { nil }

      it "renders the correct form action" do
        expect(subject).to have_element "form", action: recurring_meeting_path(recurring_meeting)
      end
    end

    context "with a current project" do
      let(:project) { build_stubbed(:project) }

      it "renders the correct form action" do
        expect(subject).to have_element "form", action: project_recurring_meeting_path(project, recurring_meeting)
      end
    end
  end

  it "shows a heading" do
    expect(subject).to have_text "Permanently delete this meeting series?"
  end

  context "with a meeting series that ends - with several remaining meetings" do
    it "shows a confirmation message with a count of the remaining meetings" do
      expect(subject).to have_text "will delete all 6 meetings in this series"
    end
  end

  context "with a meeting series that ends - with one remaining meeting" do
    let(:recurring_meeting) { build_stubbed(:recurring_meeting, project:, end_after: :iterations, iterations: 1) }

    it "shows a confirmation message mentioning one remaining meeting" do
      expect(subject).to have_text "will also delete one meeting in this series"
    end
  end

  context "with a meeting series that never ends" do
    let(:recurring_meeting) { build_stubbed(:recurring_meeting, project:, end_after: :never) }

    it "shows a confirmation message without a count" do
      expect(subject).to have_text "will delete any meetings in this series"
    end
  end
end
