# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2010-2024 the OpenProject GmbH
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

require "rails_helper"

RSpec.describe EnterpriseEdition::BannerComponent, type: :component do
  let(:title) { "Some title" }
  let(:description) { "Some description" }
  let(:href) { "https://www.example.org" }
  let(:link_title) { "Get more information" }
  let(:ee_show_banners) { true }
  let(:enforce_available_locales) { I18n.config.enforce_available_locales }
  let(:i18n_upsale) do
    {
      title:,
      link_title:,
      some_enterprise_feature: {
        description:
      }
    }
  end
  let(:static_links) do
    {
      enterprise_docs: {
        some_enterprise_feature: {
          href:
        }
      }
    }
  end

  let(:render_component) do
    render_inline(described_class.new(:some_enterprise_feature))
  end

  let(:render_component_in_mo) do
    I18n.with_locale :mo do
      render_component
    end
  end

  before do
    allow(EnterpriseToken)
      .to receive(:show_banners?)
            .and_return(ee_show_banners)
    allow(OpenProject::Static::Links)
      .to receive(:links)
            .and_return(static_links)

    I18n.config.enforce_available_locales = !enforce_available_locales

    I18n.backend.store_translations(
      :mo,
      {
        ee: {
          upsale: i18n_upsale
        }
      }
    )
  end

  after do
    I18n.backend.translations.delete(:mo)
    I18n.config.enforce_available_locales = enforce_available_locales
  end

  shared_examples_for "renders the component" do
    it "renders the component" do
      render_component_in_mo

      expect(page).to have_test_selector("op-ee-banner-some-enterprise-feature")
      expect(page).to have_css ".op-ee-banner--title-container", text: title
      expect(page).to have_css ".op-ee-banner--description-container", text: description
      expect(page).to have_link link_title, href:
    end
  end

  it_behaves_like "renders the component"

  context "with a description_html in the i18n file" do
    let(:i18n_upsale) do
      {
        title:,
        link_title:,
        some_enterprise_feature: {
          description_html: description
        }
      }
    end

    it_behaves_like "renders the component"
  end

  context "with a more specific title in the i18n file" do
    let(:i18n_upsale) do
      {
        title: "The general title",
        link_title:,
        some_enterprise_feature: {
          title:,
          description:
        }
      }
    end

    it_behaves_like "renders the component"
  end

  context "with a more specific link title in the i18n file" do
    let(:i18n_upsale) do
      {
        title:,
        link_title: "The general link title",
        some_enterprise_feature: {
          link_title:,
          description:
        }
      }
    end

    it_behaves_like "renders the component"
  end

  context "without a description key in the i18n file" do
    let(:i18n_upsale) do
      {
        title:,
        link_title:,
        some_enterprise_feature: {}
      }
    end

    it "raises an error" do
      expect { render_component_in_mo }.to raise_error(I18n::MissingTranslationData)
    end
  end

  context "without a link key in the static_link file" do
    let(:static_links) do
      {
        enterprise_docs: {
          some_enterprise_feature: {}
        }
      }
    end

    it "raises an error" do
      expect { render_component_in_mo }.to raise_error(RuntimeError)
    end
  end

  context "if banners are hidden" do
    let(:ee_show_banners) { false }

    it "hides the component" do
      render_component_in_mo

      expect(page).to have_no_css ".op-ee-banner"
    end
  end

  context "if banners are hidden but skip_render is overwritten" do
    let(:ee_show_banners) { false }
    let(:render_component) do
      render_inline(described_class.new(:some_enterprise_feature,
                                        skip_render: false))
    end

    it_behaves_like "renders the component"
  end
end
