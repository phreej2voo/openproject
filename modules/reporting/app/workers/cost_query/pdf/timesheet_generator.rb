class CostQuery::PDF::TimesheetGenerator
  include WorkPackage::PDFExport::Common::Common
  include WorkPackage::PDFExport::Common::Attachments
  include WorkPackage::PDFExport::Common::Logo
  include WorkPackage::PDFExport::Export::Cover
  include WorkPackage::PDFExport::Export::Page
  include WorkPackage::PDFExport::Export::Style
  include ReportingHelper

  H1_FONT_SIZE = 26
  H1_MARGIN_BOTTOM = 2
  HR_MARGIN_BOTTOM = 16
  TABLE_CELL_FONT_SIZE = 10
  TABLE_CELL_BORDER_COLOR = "BBBBBB".freeze
  TABLE_CELL_PADDING = 4
  COMMENT_FONT_COLOR = "636C76".freeze
  H2_FONT_SIZE = 20
  H2_MARGIN_BOTTOM = 10
  COLUMN_DATE_WIDTH = 66
  COLUMN_ACTIVITY_WIDTH = 100
  COLUMN_HOURS_WIDTH = 60
  COLUMN_TIME_WIDTH = 110
  COLUMN_WP_WIDTH = 190

  attr_accessor :pdf

  def initialize(query, project)
    @query = query
    @project = project
    @total_page_nr = nil
    @page_count = 1
    setup_page!
  end

  def heading
    query.name || I18n.t(:"export.timesheet.timesheet")
  end

  def footer_title
    heading
  end

  def cover_page_title
    "OpenProject"
  end

  def cover_page_heading
    heading
  end

  def cover_page_dates
    start_date, end_date = all_entries.map(&:spent_on).minmax
    "#{format_date(start_date)} - #{format_date(end_date)}" if start_date && end_date
  end

  def cover_page_subheading
    User.current&.name
  end

  def project
    @project
  end

  def query
    @query
  end

  def options
    {}
  end

  def setup_page!
    self.pdf = get_pdf
    configure_page_size!(:portrait)
    pdf.title = heading
  end

  def generate!
    render_doc
    if wants_total_page_nrs?
      @total_page_nr = pdf.page_count + @page_count
      @page_count = 1
      setup_page! # clear current pdf
      render_doc
    end
    pdf.render
  rescue StandardError => e
    Rails.logger.error { "Failed to generate PDF: #{e} #{e.message}}." }
    error(I18n.t(:error_pdf_failed_to_export, error: e.message))
  end

  def render_doc
    write_cover_page! if with_cover?
    write_overview!
    write_heading!
    write_hr!
    write_entries!
    write_headers!
    write_footers!
  end

  def write_entries!
    grouped_by_user_entries.each do |user, result|
      write_table(user, result)
    end
  end

  def grouped_by_user_entries
    all_entries
      .group_by(&:user)
  end

  def all_entries
    @all_entries ||= begin
      ids = query
              .each_direct_result
              .filter { |r| r.fields["type"] == "TimeEntry" }
              .flat_map { |r| r.fields["id"] }

      TimeEntry.where(id: ids).includes(%i[user activity work_package project])
    end
  end

  def build_table_rows(entries)
    rows = [table_header_columns]
    entries
      .group_by(&:spent_on)
      .sort
      .each do |spent_on, lines|
      rows.concat(build_table_day_rows(spent_on, lines))
    end
    rows.push(build_table_row_sum(entries))
    rows
  end

  def build_table_day_rows(spent_on, entries)
    day_rows = []
    entries.each do |entry|
      day_rows.push(build_table_row(spent_on, entry))
      if entry.comments.present?
        day_rows.push(build_table_row_comment(entry))
      end
    end
    day_rows
  end

  def build_table_row(spent_on, entry)
    [
      { content: format_date(spent_on), rowspan: entry.comments.present? ? 2 : 1 },
      entry.work_package&.subject || "",
      with_times_column? ? format_spent_on_time(entry) : nil,
      format_hours(entry.hours),
      entry.activity&.name || ""
    ].compact
  end

  def build_table_row_sum(entries)
    [
      { content: "", rowspan: 1 },
      "",
      with_times_column? ? "" : nil,
      { content: format_sum_time_entries(entries), font_style: :bold },
      ""
    ].compact
  end

  def format_sum_time_entries(entries)
    format_hours(sum_time_entries(entries))
  end

  def sum_time_entries(entries)
    entries.sum(&:hours)
  end

  def build_table_row_comment(entry)
    [{
      content: entry.comments,
      text_color: COMMENT_FONT_COLOR,
      font_style: :italic,
      colspan: table_columns_widths.size
    }]
  end

  def table_header_columns
    [
      { content: TimeEntry.human_attribute_name(:spent_on), rowspan: 1 },
      I18n.t(:"activerecord.models.work_package"),
      with_times_column? ? I18n.t(:"export.timesheet.time") : nil,
      TimeEntry.human_attribute_name(:hours),
      TimeEntry.human_attribute_name(:activity)
    ].compact
  end

  def table_columns_widths
    @table_columns_widths ||= if with_times_column?
                                [COLUMN_DATE_WIDTH, COLUMN_WP_WIDTH, COLUMN_TIME_WIDTH, COLUMN_HOURS_WIDTH,
                                 COLUMN_ACTIVITY_WIDTH]
                              else
                                [COLUMN_DATE_WIDTH, COLUMN_WP_WIDTH + COLUMN_TIME_WIDTH, COLUMN_HOURS_WIDTH,
                                 COLUMN_ACTIVITY_WIDTH]
                              end
  end

  def build_table(rows, has_sum_row)
    pdf.make_table(
      rows,
      header: true,
      width: table_columns_widths.sum,
      column_widths: table_columns_widths,
      cell_style: {
        size: TABLE_CELL_FONT_SIZE,
        border_color: TABLE_CELL_BORDER_COLOR,
        border_width: 0.5,
        borders: %i[top bottom],
        padding: [TABLE_CELL_PADDING, TABLE_CELL_PADDING, TABLE_CELL_PADDING + 2, TABLE_CELL_PADDING]
      }
    ) do |table|
      adjust_borders_first_column(table)
      adjust_borders_last_column(table)
      adjust_borders_spanned_column(table)
      adjust_border_header_row(table)
      adjust_border_sum_row(table) if has_sum_row
    end
  end

  def adjust_borders_first_column(table)
    table.columns(0).borders = %i[top bottom left right]
  end

  def adjust_borders_last_column(table)
    table.columns(table_columns_widths.length - 1).style do |c|
      c.borders = c.borders + [:right]
    end
  end

  def adjust_borders_spanned_column(table)
    table.columns(1).style do |c|
      if c.colspan > 1
        c.borders = %i[left right bottom]
        c.padding = [0, TABLE_CELL_PADDING, TABLE_CELL_PADDING + 2, TABLE_CELL_PADDING]
        row_nr = c.row - 1
        values = table.columns(1..-1).rows(row_nr..row_nr)
        values.each do |cell|
          cell.borders = cell.borders - [:bottom]
        end
      end
    end
  end

  def adjust_border_header_row(table)
    table.rows(0).style do |c|
      c.borders = c.borders + [:top]
      c.font_style = :bold
    end
  end

  def adjust_border_sum_row(table)
    table.rows(-1).columns(0).style do |c|
      c.borders = c.borders - [:right]
    end
  end

  def split_group_rows(table_rows)
    measure_table = build_table(table_rows, true)
    groups = []
    index = 0
    while index < table_rows.length
      row = table_rows[index]
      rows = [row]
      height = measure_table.row(index).height
      index += 1
      if (row[0][:rowspan] || 1) > 1
        rows.push(table_rows[index])
        height += measure_table.row(index).height
        index += 1
      end
      groups.push({ rows:, height: })
    end
    groups
  end

  def write_table(user, entries)
    rows = build_table_rows(entries)
    # prawn-table does not support splitting a rowspan cell on page break, so we have to merge the first column manually
    # for easier handling existing rowspan cells are grouped as one row
    grouped_rows = split_group_rows(rows)
    # start a new page if the username would be printed alone at the end of the page
    pdf.start_new_page if available_space_from_bottom < grouped_rows[0][:height] + grouped_rows[1][:height] + username_height
    write_username(user)
    write_grouped_tables(grouped_rows)
  end

  def available_space_from_bottom
    margin_bottom = pdf.options[:bottom_margin] + 20 # 20 is the safety margin
    pdf.y - margin_bottom
  end

  def write_grouped_tables(grouped_rows)
    header_row = grouped_rows[0]
    current_table = []
    current_table_height = 0
    grouped_rows.each do |grouped_row|
      grouped_row_height = grouped_row[:height]
      if current_table_height + grouped_row_height >= available_space_from_bottom
        write_grouped_row_table(current_table, false)
        pdf.start_new_page
        current_table = [header_row]
        current_table_height = header_row[:height]
      end
      current_table.push(grouped_row)
      current_table_height += grouped_row_height
    end
    write_grouped_row_table(current_table, true)
    pdf.move_down(28)
  end

  def write_grouped_row_table(grouped_rows, has_sum_row)
    current_table = []
    merge_first_columns(grouped_rows)
    grouped_rows.map! { |row| current_table.concat(row[:rows]) }
    build_table(current_table, has_sum_row).draw
  end

  def merge_first_columns(grouped_rows)
    last_row = grouped_rows[1]
    index = 2
    while index < grouped_rows.length
      grouped_row = grouped_rows[index]
      last_row = merge_first_rows(grouped_row, last_row)
      index += 1
    end
  end

  def merge_first_rows(grouped_row, last_row)
    grouped_cell = grouped_row[:rows][0][0]
    last_cell = last_row[:rows][0][0]
    if grouped_cell[:content] == last_cell[:content]
      last_cell[:rowspan] += grouped_cell[:rowspan]
      grouped_row[:rows][0].shift
      last_row
    else
      grouped_row
    end
  end

  def sorted_results
    query.each_direct_result.map(&:itself)
  end

  def write_hr!
    hr_style = styles.cover_header_border
    write_horizontal_line(pdf.cursor, hr_style[:height], hr_style[:color])
    pdf.move_down(HR_MARGIN_BOTTOM)
  end

  def write_overview!
    groups = grouped_by_user_entries
    return if groups.size <= 1

    write_heading!
    write_hr!
    write_overview_table!(overview_table_rows(groups))

    start_new_page_if_needed
  end

  def write_overview_table!(rows)
    pdf.make_table(
      rows,
      header: true,
      width: pdf.bounds.width,
      cell_style: {
        size: TABLE_CELL_FONT_SIZE,
        border_color: TABLE_CELL_BORDER_COLOR,
        border_width: 0.5,
        borders: %i[top bottom left right],
        padding: [TABLE_CELL_PADDING, TABLE_CELL_PADDING, TABLE_CELL_PADDING + 2, TABLE_CELL_PADDING]
      }
    ) do |table|
      adjust_overview_border_sum_row(table)
    end.draw
  end

  def adjust_overview_border_sum_row(table)
    row = table.rows(-1)
    row.columns(0).style { |c| c.borders = c.borders - [:right] }
    row.columns(-1).style { |c| c.borders = c.borders - [:left] }
  end

  def overview_table_rows(groups)
    rows = [
      [
        { content: TimeEntry.human_attribute_name(:user), font_style: :bold },
        { content: I18n.t("export.timesheet.sum_hours"), font_style: :bold }
      ]
    ]
    groups.each do |user, entries|
      rows.push([user.name, format_sum_time_entries(entries)])
    end

    total = groups.sum { |_user, entries| entries.sum(&:hours) }
    rows.push(["", { content: format_hours(total), font_style: :bold }])
    rows
  end

  def write_heading!
    pdf.formatted_text([{ text: heading, size: H1_FONT_SIZE, style: :bold }])
    pdf.move_down(H1_MARGIN_BOTTOM)
  end

  def username_height
    20 + 10
  end

  def write_username(user)
    pdf.formatted_text([{ text: user.name, size: H2_FONT_SIZE }])
    pdf.move_down(H2_MARGIN_BOTTOM)
  end

  def footer_date
    if pdf.page_number == 1
      format_time(Time.zone.now)
    else
      format_date(Time.zone.now)
    end
  end

  def format_hours(hours)
    return "" if hours < 0

    DurationConverter.output(hours)
  end

  def format_spent_on_time(entry)
    spent_on_time_representation(entry.start_timestamp, entry.hours)
  end

  def with_times_column?
    Setting.allow_tracking_start_and_end_times
  end

  def with_cover?
    true
  end

  def wants_total_page_nrs?
    true
  end
end
