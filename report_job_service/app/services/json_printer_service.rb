class JsonPrinterService < ApplicationService
  attr_reader :historical

  def initialize(historical)
    @historical = historical
  end

  def call
    @historical.map do |currency, data|
      filename = File.join(__dir__, '..', '..', 'tmp', "#{currency}_evolution_#{Date.today.strftime("%Y-%m-%d")}.json")
      File.open(filename, 'w') do |f|
        f.write(data.to_json)
      end
      filename
    end
  end
end