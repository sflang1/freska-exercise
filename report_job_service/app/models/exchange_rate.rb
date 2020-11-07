class ExchangeRate < ActiveRecord::Base
  validates_presence_of :rate, :from, :to, :date


  # I had to write this method because I want that if you ask for USD-EUR, you are able to respond it with a EUR-USD exchange rate
  def to_renderable_json(desired_base_currency)
    {
      date: date,
      from: desired_base_currency,
      to: desired_base_currency == from ? to : from,
      rate: desired_base_currency == from ? rate : (1/rate).round(6)
    }
  end
end