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

RSpec.describe Meetings::SidePanel::DetailsComponent, type: :component do
  let(:user) { build_stubbed(:user) }

  subject do
    render_inline(described_class.new(meeting:))
    page
  end

  before do
    login_as(user)
  end

  context "with templated meeting and working_days frequency" do
    let(:series) do
      build_stubbed(:recurring_meeting,
                    start_time: DateTime.parse("2024-12-04T10:00:00Z"),
                    frequency: "working_days")
    end
    let(:meeting) do
      build_stubbed(:structured_meeting_template,
                    recurring_meeting: series)
    end

    it "doesn't show the weekday" do
      expect(subject).to have_no_text("Wednesday")
    end
  end

  context "with templated meeting and weekly frequency" do
    let(:series) do
      build_stubbed(:recurring_meeting,
                    start_time: DateTime.parse("2024-12-04T10:00:00Z"),
                    frequency: "weekly")
    end
    let(:meeting) do
      build_stubbed(:structured_meeting_template,
                    recurring_meeting: series)
    end

    it "shows the weekday" do
      expect(subject).to have_text("Wednesday")
    end
  end
end
