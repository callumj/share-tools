require 'mechanize'

class EtradeAccount

  ROOT = "https://invest.etrade.com.au/Home.aspx"

  attr_reader :client, :user, :password

  def initialize(user = Settings.etrade.user_id, password = Settings.etrade.password)
    @client = Mechanize.new
    cert_store = OpenSSL::X509::Store.new
    cert_store.add_file File.join(APP_ROOT, "data", "cacert.pem")
    client.cert_store = cert_store
    @user = user
    @password = password

    authenticate
  end

  def authenticate
    page = client.get(ROOT)
    form = page.form("Form1")

    user_field = form.fields.detect { |f| f.name.match(/UserName/) }
    pass_field = form.fields.detect { |f| f.name.match(/Password/) }
    user_field.value = @user
    pass_field.value = password

    form['__EVENTTARGET'] = "ctlLogin$btnLogin"
    form['__EVENTARGUMENT'] = "Click"

    result = client.submit form
  end

  def portfolio
    page = portfolio_page
    total_value = page.at("span#miniTab_ucPortfolios_lblTotalMarketValueAUDValue").try :inner_text
    total_value.gsub!(/[$,]/, "")

    gain = page.at("div#miniTab_ucPortfolios_pnlPortFolioSummary").css(".gain.shown").last.inner_text
    gain.gsub!(/[$,]/, "")

    shares = extract_shares page

    {
      total_value: total_value.to_f,
      gain:        gain.to_f,
      shares:      shares
    }
  end

  private

    def portfolio_page
      client.get "/Portfolios/Portfolios/Default.aspx"
    end

    def extract_shares(page = portfolio_page)
      table = page.at("#miniTab_ucPortfolios_dgSharesASX")
      rows = table.css("tr")

      share_set = {}
      rows.each do |row|
        next if row.inner_text.match(/^Code/)
        tds = row.css("td")
        code = tds[0].inner_text
        quantity = tds[1].inner_text.gsub(/[$,]/, "").to_f
        cost_basis = tds[3].inner_text.to_f
        last_price = tds[5].inner_text.to_f
        gain       = tds[7].inner_text.gsub(/[$,]/, "").to_f
        total      = tds[8].inner_text.gsub(/[$,]/, "").to_f

        data = {
          quantity:   quantity,
          cost_basis: cost_basis,
          last_price: last_price,
          gain:       gain,
          total:      total
        }
        share_set[code] = data
      end

      share_set
    end

end
