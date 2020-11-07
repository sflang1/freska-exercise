require 'axlsx'

class XlsxPrinterService < ApplicationService
  attr_reader :historical

  def initialize(historical)
    @historical = historical
  end

  def call
    p = Axlsx::Package.new
    wb = p.workbook
    @historical.map do |currency, data|
      wb.add_worksheet(name: currency.to_s) do |sheet|
        sheet.add_row ['Date reported', 'Currency value today', 'Currency value that day', 'Delta']
        data.each do |row|
          sheet.add_row [row[:report_date], row[:currency_today], row[:currency_that_date], row[:delta]]
        end
      end
    end
    
    filename = File.join(__dir__, '..', '..', 'tmp', "currency_evolution_#{Date.today.strftime("%Y-%m-%d")}.xlsx")
    p.serialize filename
    filename
  end
end