# frozen_string_literal: true

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

module EnterpriseEdition
  # A banner indicating that a given feature requires the enterprise edition of OpenProject.
  # This component uses conventional names for translation keys or URL look-ups based on the feature_key passed in.
  # It will only be rendered if necessary.
  class BannerComponent < ApplicationComponent
    include OpPrimer::ComponentHelpers

    # @param feature_key [Symbol, NilClass] The key of the feature to show the banner for.
    # @param title [String] The title of the banner.
    # @param description [String] The description of the banner.
    # @param href [String] The URL to link to.
    # @param skip_render [Boolean] Whether to skip rendering the banner.
    # @param system_arguments [Hash] <%= link_to_system_arguments_docs %>
    def initialize(feature_key,
                   title: nil,
                   description: nil,
                   link_title: nil,
                   href: nil,
                   skip_render: !EnterpriseToken.show_banners?,
                   **system_arguments)
      @system_arguments = system_arguments
      @system_arguments[:tag] = "div"
      @system_arguments[:test_selector] = "op-ee-banner-#{feature_key.to_s.tr('_', '-')}"
      super

      @feature_key = feature_key
      @title = title
      @description = description
      @link_title = link_title
      @href = href
      @skip_render = skip_render
    end

    private

    attr_reader :skip_render,
                :feature_key

    def title
      @title || I18n.t("ee.upsale.#{feature_key}.title", default: I18n.t("ee.upsale.title"))
    end

    def description
      @description || begin
        I18n.t("ee.upsale.#{feature_key}.description")
      rescue StandardError
        I18n.t("ee.upsale.#{feature_key}.description_html")
      end
    rescue I18n::MissingTranslationData => e
      raise e.exception(
        <<~TEXT.squish
          The expected '#{I18n.locale}.ee.upsale.#{feature_key}.description' key does not exist.
          Ideally, provide it in the locale file.
          If that isn't applicable, a description parameter needs to be provided.
        TEXT
      )
    end

    def link_title
      @link_title || I18n.t("ee.upsale.#{feature_key}.link_title", default: I18n.t("ee.upsale.link_title"))
    end

    def href
      href_value = @href || OpenProject::Static::Links.links.dig(:enterprise_docs, feature_key, :href)

      unless href_value
        raise "Neither a custom href is provided nor is a value set " \
              "in OpenProject::Static::Links.enterprise_docs[#{feature_key}][:href]"
      end

      href_value
    end

    def render?
      !skip_render
    end
  end
end
