task :notify do
  e = EtradeAccount.new
  sp = Spreadsheet.new

  last_values = sp.last_day_values
  cur_values  = e.portfolio

  gain_str = ""
  if last_values
    diff = cur_values[:gain].to_f - last_values[:gain].to_f
    change = (cur_values[:gain].to_f / last_values[:gain].to_f).round(2)
    gain_str = "Change by #{diff} (#{change}%)."
  end

  title = "E*Trade portfolio at $#{cur_values[:total_value]} ($#{cur_values[:gain]})"

  Pushover.notification(message: gain_str, title: title, user: Settings.pushover.user_token, token: Settings.pushover.app_token)
end