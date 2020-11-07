require 'csv'

class CsvPrinterService < ApplicationService
  attr_reader :historical

  def initialize(historical)
    @historical = historical
  end

  def call
    @historical.map do |currency, data|
      filename = File.join(__dir__, '..', '..', 'tmp', "#{currency}_evolution_#{Date.today.strftime("%Y-%m-%d")}.csv")
      CSV.open(filename, 'w') do |csv|
        csv << ['Date reported', 'Currency value today', 'Currency value that day', 'Delta']
        data.each do |row|
          csv << [row[:report_date], row[:currency_today], row[:currency_that_date], row[:delta]]
        end
      end
      filename
    end
  end
end