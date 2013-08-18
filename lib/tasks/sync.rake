desc "Sync portfolio state to Google"
task :sync do
  e = EtradeAccount.new
  sp = Spreadsheet.new

  data = e.portfolio
  sp.update_portfolio data[:total_value], data[:gain]

  data[:shares].each do |code, share_data|
    sp.update_share code, share_data
  end
end