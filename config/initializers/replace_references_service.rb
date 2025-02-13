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

Rails.application.reloader.to_prepare do
  Principals::ReplaceReferencesService.add_replacements(
    {
      "AuthProvider" => :creator_id,
      "Attachment" => :author_id,
      "Budget" => :author_id,
      "Changeset" => :user_id,
      "Comment" => :author_id,
      "CostEntry" => %i[logged_by_id user_id],
      "CostQuery" => :user_id,
      "::Doorkeeper::Application" => :owner_id,
      "MeetingAgenda" => :author_id,
      "MeetingAgendaItem" => %i[author_id presenter_id],
      "MeetingMinutes" => :author_id,
      "MeetingParticipant" => :user_id,
      "Message" => :author_id,
      "News" => :author_id,
      "::Notification" => :actor_id,
      "::Query" => :user_id,
      "TimeEntry" => %i[logged_by_id user_id],
      "WikiPage" => :author_id,
      "WorkPackage" => %i[author_id assigned_to_id responsible_id]
    }
  )
end
