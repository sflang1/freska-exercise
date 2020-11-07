require 'spec_helper'
require 'rails_helper'

RSpec.describe 'convert currency', type: :request do
  before :example do
    allow(FixerApiQueryService).to receive(:call).and_return([
      { date: "2020-02-03", from: "EUR", to: "USD", rate: 1.23123 },
      { date: "2020-02-04", from: "EUR", to: "USD", rate: 1.24 },
    ])
  end
  
  it 'should show a bad request error if a param is not present' do
    get '/api/currencies/convert/EUR'
    expect(response.status).to eq 400
    
    get '/api/currencies/convert/EUR?start_date=2020-03-04'
    expect(response.status).to eq 400

    get '/api/currencies/convert/EUR?start_date=2020-03-04&end_date=2020-03-05'
    expect(response.status).to eq 400
  end

  it 'should fail if end date is previous to start date' do
    get '/api/currencies/convert/EUR?start_date=2020-03-05&end_date=2020-03-03&to=USD'
    expect(response.status).to eq 400
  end
  
  it 'should pass if all parameters are given' do 
    get '/api/currencies/convert/EUR?start_date=2020-02-03&end_date=2020-02-04&to=USD'
    expect(response.status).to eq 200
  end

  it 'should not call the api if a day is already in the database' do
    # Create some days before the test
    ExchangeRate.create([
      { date: "2020-02-03", from: "EUR", to: "USD", rate: 1.23123 },
      { date: "2020-02-04", from: "EUR", to: "USD", rate: 1.24 }
    ])
    expect(FixerApiQueryService).not_to receive(:call)
    
    get '/api/currencies/convert/EUR?start_date=2020-02-03&end_date=2020-02-04&to=USD'
  end
  
  it 'should not call the api if the inverse exchange rate is already in the database' do 
    ExchangeRate.create(date: "2020-02-03", from: "EUR", to: "USD", rate: 1.23123 )
    expect(FixerApiQueryService).not_to receive(:call)
    
    get '/api/currencies/convert/USD?start_date=2020-02-03&end_date=2020-02-03&to=EUR'
  end

  it 'should render the proper inverse rate if it is already in the DB' do 
    date = "2020-02-03"
    ExchangeRate.create(date: date, from: "EUR", to: "USD", rate: 1.23123 )
    expect(FixerApiQueryService).not_to receive(:call)
    
    get '/api/currencies/convert/USD?start_date=2020-02-03&end_date=2020-02-03&to=EUR'
    parsed_object = JSON.parse(response.body)
    date_element = parsed_object.find{ |el| el["date"] == date}
    expect(date_element).not_to be_nil
    expect(date_element["rate"]).to eq (1/1.23123).round(6)
  end

  it 'should save the results of what the api responds' do
    expect(ExchangeRate.count).to eq 0
    get '/api/currencies/convert/EUR?start_date=2020-02-03&end_date=2020-02-04&to=USD'

    # Our mocked results are in the before example block
    expect(ExchangeRate.count).to eq 2
    exchange_rate_1 = ExchangeRate.find_by(date: "2020-02-03", from: "EUR", to: "USD")
    expect(exchange_rate_1).not_to be_nil
    expect(exchange_rate_1.rate).to eq 1.23123
    exchange_rate_2 = ExchangeRate.find_by(date: "2020-02-04", from: "EUR", to: "USD")
    expect(exchange_rate_2).not_to be_nil
    expect(exchange_rate_2.rate).to eq 1.24
  end
end