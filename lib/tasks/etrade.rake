namespace :etrade do

  desc "List portfolio state"
  task :portfolio do
    e = EtradeAccount.new
    data = e.portfolio

    STDOUT.puts "Total: #{data[:total_value]}"

    rows = data[:shares].map do |code, set|
      [code, *set.map(&:last)]
    end

    table = Terminal::Table.new headings: ["Code", "Quantity", "Cost Basis", "Last Price", "Gain", "Total"], rows: rows
    puts table
  end

end
