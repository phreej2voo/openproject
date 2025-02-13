#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
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

module WorkPackages
  module ActivitiesTab
    module Journals
      class ItemComponent::AddReactions < ApplicationComponent
        include ApplicationHelper
        include OpPrimer::ComponentHelpers
        include OpTurbo::Streamable

        def initialize(journal:, grouped_emoji_reactions:)
          super

          @journal = journal
          @grouped_emoji_reactions = grouped_emoji_reactions || {}
        end

        def render?
          current_user_can_react?
        end

        private

        attr_reader :journal, :grouped_emoji_reactions

        def counter_color(reaction)
          reacted_by_current_user?(reaction) ? :accent : nil
        end

        def button_scheme(reaction)
          reacted_by_current_user?(reaction) ? :default : :invisible
        end

        def reacted_by_current_user?(reaction)
          return false if grouped_emoji_reactions.blank?

          grouped_emoji_reactions.dig(reaction, :users)&.any? { |u| u[:id] == User.current.id }
        end

        def href(reaction:)
          return if current_user_cannot_react?

          toggle_reaction_work_package_activity_path(journal.journable.id, id: journal.id, reaction:)
        end

        def work_package = journal.journable
        def wrapper_uniq_by = journal.id

        def current_user_can_react?
          User.current.allowed_in_work_package?(:add_work_package_notes, work_package)
        end

        def current_user_cannot_react? = !current_user_can_react?
      end
    end
  end
end
