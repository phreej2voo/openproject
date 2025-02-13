require "active_storage/filename"

class CostQuery::XLS::ExportJob < Exports::ExportJob
  self.model = ::CostQuery

  def project
    options[:project]
  end

  def cost_types
    options[:cost_types]
  end

  def title
    I18n.t("export.cost_reports.title")
  end

  private

  def prepare!
    CostQuery::Cache.check
    self.query = CostQuery.build_query(project, query)
  end

  def export!
    # Build an xls file from a cost report.
    # We only support extracting a simple xls table, so grouping is ignored.
    handle_export_result(export, xls_report_result)
  end

  def xls_report_result
    params = { query:, project:, cost_types: }
    content = ::OpenProject::Reporting::CostEntryXlsTable.generate(params).xls
    time = Time.current.strftime("%Y-%m-%d-T-%H-%M-%S")
    export_title = "cost-report-#{time}.xls"

    ::Exports::Result.new(format: :xls,
                          title: export_title,
                          mime_type: "application/vnd.ms-excel",
                          content:)
  end
end
