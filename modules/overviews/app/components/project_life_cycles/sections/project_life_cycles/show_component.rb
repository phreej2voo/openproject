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

module ProjectLifeCycles
  module Sections
    module ProjectLifeCycles
      class ShowComponent < ApplicationComponent
        include ApplicationHelper
        include OpPrimer::ComponentHelpers

        private

        def not_set?
          model.not_set?
        end

        def render_value
          render(Primer::Beta::Text.new) do
            concat [
              model.start_date,
              model.end_date
            ]
            .compact
            .map { |d| helpers.format_date(d) }
            .join(" - ")
          end
        end

        def icon
          case model
          when Project::Stage
            :"git-commit"
          when Project::Gate
            :diamond
          else
            raise NotImplementedError, "Unknown model #{model.class} to render a LifeCycleForm with"
          end
        end

        def icon_color_class
          helpers.hl_inline_class("life_cycle_step_definition", model.definition)
        end

        def text
          model.name
        end
      end
    end
  end
end
