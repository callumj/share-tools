class Spreadsheet
  NAME = "Share holdings"

  attr_reader :session, :spreadsheet

  def initialize(user = Settings.google.user, password = Settings.google.password)
    @session = GoogleDrive.login(user, password)
    @spreadsheet = session.spreadsheet_by_title NAME
  end

  def update_portfolio(value)
    cur_date = Time.now

    portfolio_requires_change = portfolio_sheet.num_rows <= 1
    portfolio_requires_change = true if !portfolio_requires_change && (portfolio_sheet.rows.last[1].to_s != value.to_s)

    if portfolio_requires_change
      row_id = portfolio_sheet.num_rows + 1
      portfolio_sheet[row_id, 1] = cur_date.to_s(:long)
      portfolio_sheet[row_id, 2] = value
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

  private

    def portfolio_sheet
      @portfolio_sheet ||= spreadsheet.worksheets[0]
    end

    def shares_sheet
      @shares_sheet ||= spreadsheet.worksheets[1]
    end
end
