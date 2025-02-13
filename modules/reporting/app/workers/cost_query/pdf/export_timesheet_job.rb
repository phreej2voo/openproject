require "active_storage/filename"

class CostQuery::PDF::ExportTimesheetJob < Exports::ExportJob
  self.model = ::CostQuery

  def project
    options[:project]
  end

  def title
    I18n.t("export.timesheet.title")
  end

  private

  def export!
    handle_export_result(export, pdf_report_result)
  end

  def prepare!
    CostQuery::Cache.check
    self.query = CostQuery.build_query(project, query)
    query.name = options[:query_name]
  end

  def pdf_report_result
    content = generate_timesheet
    time = Time.current.strftime("%Y-%m-%d-T-%H-%M-%S")
    export_title = "timesheet-#{time}.pdf"
    ::Exports::Result.new(format: :pdf,
                          title: export_title,
                          mime_type: "application/pdf",
                          content:)
  end

  def generate_timesheet
    generator = ::CostQuery::PDF::TimesheetGenerator.new(query, project)
    generator.generate!
  end
end
