require 'net/http'

class FixerApiQueryService < ApplicationService

  attr_reader :base_currency, :to_currency, :days_required

  def initialize(base_currency, to_currency, days_required)
    @base_currency = base_currency
    @to_currency = to_currency
    @days_required = days_required
  end

  def call
    return false if ENV['FIXER_IO_API_KEY'].blank?
    days_required.map do |date|
      url = URI("http://data.fixer.io/api/#{date.strftime("%Y-%m-%d")}?access_key=#{ENV['FIXER_IO_API_KEY']}&base=#{@base_currency}&symbols=#{@to_currency}")
      result = Net::HTTP.get_response(url)
      parsed_result = JSON.parse(result.body)
      return false unless parsed_result["success"]
      {from: @base_currency, date: date, to: @to_currency, rate: parsed_result["rates"][@to_currency]}
    end
  end
end