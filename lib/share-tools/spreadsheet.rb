class Spreadsheet
  NAME = "Share holdings"

  attr_reader :session, :spreadsheet

  def initialize(user = Settings.google.user, password = Settings.google.password)
    @session = GoogleDrive.login(user, password)
    @spreadsheet = session.spreadsheet_by_title NAME
  end

  def update_portfolio(total, gain)
    cur_time = Time.now

    portfolio_requires_change = portfolio_sheet.num_rows <= 1
    portfolio_requires_change = true if !portfolio_requires_change && (portfolio_sheet.rows.last[1].to_s != value.to_s)

    if portfolio_requires_change
      row_id = portfolio_sheet.num_rows + 1
      portfolio_sheet[row_id, 1] = cur_time.to_s
      portfolio_sheet[row_id, 2] = total
      portfolio_sheet[row_id, 3] = gain
      portfolio_sheet.save
    end
  end

  def update_share(code, share_data)
    current_shares = shares_sheet.rows
    share_index = current_shares.index { |set| set[0] == code }
    if share_index.nil?
      share_index = (shares_sheet.num_rows + 1)
      shares_sheet[share_index, 1] = code
    else
      share_index = share_index + 1
    end

    shares_sheet[share_index, 2] = share_data[:quantity]
    shares_sheet[share_index, 3] = share_data[:cost_basis]
    shares_sheet[share_index, 4] = share_data[:last_price]
    shares_sheet[share_index, 5] = share_data[:gain]
    shares_sheet[share_index, 6] = share_data[:total]
    shares_sheet.save
  end

  def last_day_values
    cur_time = Time.now

    viewable_rows = portfolio_sheet.rows[1..portfolio_sheet.num_rows]
    most_recent = viewable_rows.last(10)
    parsed = most_recent.map do |row|
      d = Time.parse(row[0])
      next nil if d.day == cur_time.day && d.month == cur_time.month && d.year == cur_time.year
      [d, *row]
    end.compact

    closest = parsed.sort_by { |row| cur_time - row[0] }.first
    return nil unless closest
    {
      total_value: closest[2],
      gain:        closest[3]
    }
  end

  private

    def portfolio_sheet
      @portfolio_sheet ||= spreadsheet.worksheets[0]
    end

    def shares_sheet
      @shares_sheet ||= spreadsheet.worksheets[1]
    end
end
