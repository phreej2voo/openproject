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

module OpenProject
  module Static
    module Links
      class << self
        def help_link_overridden?
          OpenProject::Configuration.force_help_link.present?
        end

        def help_link
          OpenProject::Configuration.force_help_link.presence || static_links[:user_guides]
        end

        delegate :[], to: :links

        def links
          @links ||= static_links.merge(dynamic_links)
        end

        def url_for(item)
          links.dig(item, :href)
        end

        def has?(name)
          @links.key? name
        end

        private

        def dynamic_links
          dynamic = {
            help: {
              href: help_link,
              label: "top_menu.help_and_support"
            }
          }

          if impressum_link = OpenProject::Configuration.impressum_link
            dynamic[:impressum] = {
              href: impressum_link,
              label: "homescreen.links.impressum"
            }
          end

          dynamic
        end

        def static_links
          @static_links ||= begin
            yaml = Rails.root.join("config/static_links.yml").read
            YAML.safe_load(yaml, permitted_classes: [Symbol], symbolize_names: true)
          end
        end
      end
    end
  end
end
