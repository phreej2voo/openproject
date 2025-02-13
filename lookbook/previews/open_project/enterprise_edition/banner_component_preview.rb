# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2024 the OpenProject GmbH
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

module OpenProject
  module EnterpriseEdition
    # @logical_path OpenProject/EnterpriseEdition
    class BannerComponentPreview < Lookbook::Preview
      # The easiest way to render the banner component is to provide a feature key and
      # have the assorted data structures match the expectations.
      # The text will be fetched from the i18n files:
      # ```
      # en:
      #   ee:
      #     # Title used unless it is overwritten for the specific feature
      #     title: "Enterprise add-on"
      #     # Title of the link used unless it is overwritten for the specific feature
      #     link_title: "More information"
      #     upsale:
      #       [feature_key]:
      #         # Title used for this feature only. If this is missing, the default title is used.
      #         title: "A splendid feature"
      #         # Could also be description_html if necessary
      #         description: "This is a splendid feature that you should use. It just might transform your life."
      #         # Title of the link used for this feature only. If this is missing, the default link title is used.
      #         title_link: "Even more information"
      # ```
      #
      # The href is inferred from `OpenProject::Static::Links.enterprise_docs[feature_key][:href]`.
      #
      # The value of `EnterpriseToken.show_banners?` is used to determine whether the banner should be shown. For this
      # example, that value is overwritten as the banner might otherwise not show up in the preview.
      def default
        render(
          ::EnterpriseEdition::BannerComponent
            .new(:customize_life_cycle,
                 skip_render: false)
        )
      end

      # The defaults can be completely overwritten. This should be used sparingly.
      def manual_overwrite
        render(
          ::EnterpriseEdition::BannerComponent
            .new(nil,
                 title: "A splendid feature",
                 description: "This is a splendid feature that you should use. It just might transform your life.",
                 href: "https://www.openproject.org",
                 link_title: "Get more information",
                 skip_render: false)
        )
      end
    end
  end
end
