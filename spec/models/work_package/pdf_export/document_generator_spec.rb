require "spec_helper"
require "text/hyphen"

RSpec.describe WorkPackage::PDFExport::DocumentGenerator do
  include Redmine::I18n
  include PDFExportSpecUtils

  let(:project) { create(:project) }
  let(:user) { create(:admin) }
  let(:description) do
    "This is a test description with an macro: workPackageValue:assignee"
  end
  let(:work_package) do
    create(:work_package,
           project:,
           description:,
           assigned_to: user,
           subject: "Document Generator Specs",
           type:)
  end
  let(:type) { create(:type) }
  let(:options) do
    {}
  end
  let(:shared_options) do
    {
      header_text_right: "A text on the right of the header",
      footer_text_center: "A text in the center of the footer"
    }
  end
  let(:exporter) do
    described_class.new(work_package, shared_options.merge(options))
  end
  let(:export) do
    login_as(user)
    exporter
  end
  let(:export_time) { DateTime.new(2023, 6, 30, 23, 59) }
  let(:export_time_formatted) { format_time(export_time, include_date: true) }
  let(:export_pdf) do
    Timecop.freeze(export_time) do
      export.export!
    end
  end

  subject(:pdf) do
    content = export_pdf.content
    # If you want to actually see the PDF for debugging, uncomment the following line
    # File.binwrite("WorkPackageDocumentGenerator-test-preview.pdf", content)
    PDF::Inspector::Text.analyze(content).strings
  end

  describe "with a request for a PDF" do
    it "contains correct data" do
      expected_result = [
        "This is a test description with an macro:",
        user.name,
        export_time_formatted,
        "A text in the center of the footer",
        "Page 1 of 1",
        "A text on the right of the header"
      ]
      result = pdf
      expect(result.join(" ")).to eq(expected_result.join(" "))
    end

    describe "with a request for a PDF with hyphenation and no header/footer text" do
      let(:options) do
        {
          hyphenation: "en_us",
          header_text_right: "",
          footer_text_center: ""
        }
      end
      let(:description) do
        "honorificabilitudinitatibus " * 6
      end

      it "contains correct data" do
        expected_result = [
          "honorificabilitudinitatibus honorificabilitudinitatibus honorificabilitudinitatibus " \
          "honorificabili ­ tudinitatibus honorificabilitudinitatibus honorificabilitudinitatibus",
          export_time_formatted,
          "Page 1 of 1"
        ]
        result = pdf
        expect(result.join(" ")).to eq(expected_result.join(" "))
      end
    end
  end
end
