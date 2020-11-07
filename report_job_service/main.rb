require 'active_record'
require 'dotenv/load'
require 'optparse'

# Establish an active record connection
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: ENV['DATABASE_HOST'],
  username: ENV['DATABASE_USERNAME'],
  password: ENV['DATABASE_PASSWORD'],
  database: ENV['DATABASE_NAME']
)

# defining currencies 

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: main.py --currencies "USD, JPY, CNY" --formats "csv, xls, html, json"'
  
  opts.on("-C", "--currencies CURRENCIES", 'A list of comma separated currency acronyms between double quotes (USD, JPY, CNY)') do |currencies|
    options[:currencies] = currencies
  end
  
  opts.on("-F", "--formats FORMATS", 'A list of comma separated formats between double quotes (CSV, XLS, HTML, JSON)') do |formats|
    options[:formats] = formats
  end
end.parse!

p 'Invalid input' if options[:currencies].nil? || options[:formats].nil?
exit if options[:currencies].nil? || options[:formats].nil?

currencies_to_assess = options[:currencies].split(',').map(&:strip)
formats = options[:formats].split(',').map(&:strip)

p 'Invalid input' if currencies_to_assess.count == 0 || formats.count == 0
exit if currencies_to_assess.count == 0 || formats.count == 0

# Adding my model
Dir[File.join(__dir__, 'app', 'models', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'app', 'services', '*.rb')].each { |file| require file }

# Creating the historical function
def get_historical(currency_to_compare, currency_pattern)
  # Start the task
  today = Date.today
  yesterday = today - 1.day
  last_week = today - 7.day
  last_month = today - 1.month
  last_year = today - 1.year
  
  dates = [today, yesterday, last_week, last_month, last_year]

  exchange_rates = dates.map do |date|
    
    saved_exchange_rate = ExchangeRate.where(date: date)
            .where('("exchange_rates"."from" = ? AND "exchange_rates"."to" = ?) OR ("exchange_rates"."from" = ? AND "exchange_rates"."to" = ?)', 
            currency_to_compare, currency_pattern, currency_pattern, currency_to_compare)
    if saved_exchange_rate.count == 0
      api_result = FixerApiQueryService.call(currency_pattern, currency_to_compare, [date])
      filtered_results = api_result.filter{|element| element}
      if filtered_results.count > 0
        new_exchange_rate = ExchangeRate.create(api_result[0])
        new_exchange_rate.to_renderable_json(currency_to_compare)
      else
        raise 'Error obtaining data from API'
      end
    else
      saved_exchange_rate.first.to_renderable_json(currency_to_compare)
    end
  end

  # all exchange rates from the next to today to the last
  exchange_rates[1..-1].map do |exchange_rate|
    {
      report_date: exchange_rate[:date],
      currency_today: exchange_rates[0][:rate],
      currency_that_date: exchange_rate[:rate],
      delta: (exchange_rates[0][:rate] - exchange_rate[:rate]).round(6)
    }
  end
end


# Instead of the approach followed in the web service, I will use this one: (reasoning in the Readme.md)
historical = {}
currencies_to_assess.each do |currency|
  historical[currency.to_sym] = get_historical(currency, currency == "EUR" ? "USD" : "EUR")
end

file_paths = []

formats.each do |format|
  case format
  when "csv"
    file_paths << CsvPrinterService.call(historical)
  when "xls"
    file_paths << XlsxPrinterService.call(historical)
  when "html"
    file_paths << HtmlPrinterService.call(historical)
  when "json"
    file_paths << JsonPrinterService.call(historical)
  else
    raise 'Unsupported format!'
  end
end

file_paths = file_paths.flatten

AmazonUploaderService.call(file_paths) if ENV['ENV'] == 'production'