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

require "spec_helper"
require "features/work_packages/work_packages_page"

RSpec.describe "work package PDF generator", :js, :selenium, with_flag: { generate_pdf_from_work_package: true } do
  let(:user) { create(:admin) }
  let(:project) { create(:project) }
  let(:default_footer_text) { work_package.subject }
  let(:default_header_text) { "#{work_package.type} ##{work_package.id}" }
  let(:expected_params) do
    default_expected_params
  end
  let(:default_expected_params) do
    {
      header_text_right: default_header_text,
      footer_text_center: default_footer_text,
      hyphenation: "",
      paper_size: "A4"
    }
  end
  let(:download_list) do
    DownloadList.new
  end
  let(:work_package) do
    build(:work_package,
          project:,
          id: 666,
          assigned_to: user,
          responsible: user)
  end
  let(:document_generator) { instance_double(WorkPackage::PDFExport::DocumentGenerator) }

  RSpec::Matchers.define :has_mandatory_params do |expected|
    match do |actual|
      expected.count do |key, value|
        actual[key.to_sym] == value
      end == expected.size
    end
  end

  def visit_work_package_page!
    wp_page = Pages::FullWorkPackage.new(work_package)
    wp_page.visit!
  end

  def mock_generating_pdf
    allow(WorkPackage::PDFExport::DocumentGenerator)
      .to receive(:new)
            .and_return(document_generator)
    allow(document_generator)
      .to receive(:initialize)
            .with(work_package, has_mandatory_params(expected_params))
    allow(document_generator)
      .to receive(:export!)
            .and_return(
              Exports::Result.new(
                format: :pdf, title: "filename.pdf", content: "PDF Content", mime_type: "application/pdf"
              )
            )
  end

  def open_generate_pdf_dialog!
    click_link_or_button "More"
    click_link_or_button "Generate PDF"
  end

  def generate!
    click_link_or_button "Generate"
    expect(subject).to have_text("filename.pdf")
  end

  before do
    mock_generating_pdf
    login_as(user)
    work_package.save!
    visit_work_package_page!
    open_generate_pdf_dialog!
  end

  after do
    DownloadList.clear
  end

  subject { download_list.refresh_from(page).latest_download.to_s }

  context "with default parameters" do
    it "downloads with options" do
      generate!
    end
  end

  context "with custom parameters" do
    let(:expected_params) do
      default_expected_params.merge({
                                      header_text_right: "Custom Header Text",
                                      footer_text_center: "Custom Footer Text",
                                      hyphenation: "de",
                                      paper_size: "LETTER"
                                    })
    end

    it "downloads with options" do
      select "Letter", from: "paper_size"
      select "Deutsch", from: "hyphenation"
      fill_in "header_text_right", with: "Custom Header Text"
      fill_in "footer_text_center", with: "Custom Footer Text"
      generate!
    end
  end
end
