class Api::CurrenciesController < ApplicationController
  before_action :validate_params, only: [:convert]

  def convert
    # Bring all records that might be pre-saved in just one query
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    # Consider that if we have a EUR - USD rate, we also have the USD - EUR
    
    saved_exchange_rates = ExchangeRate.where(date: start_date..end_date)
                                        .where('("exchange_rates"."from" = ? AND "exchange_rates"."to" = ?) OR ("exchange_rates"."from" = ? AND "exchange_rates"."to" = ?)', 
-                                       params[:base_currency], params[:to], params[:to], params[:base_currency])
                                        .order(:date)
    records_holder = saved_exchange_rates.to_a
    unfound_records = (start_date..end_date).filter { |date| !saved_exchange_rates.where(date: date).exists? }
    # If unfound records, I need to ask them to the API
    if unfound_records.count > 0
      result = FixerApiQueryService.call(params[:base_currency], params[:to], unfound_records)
      new_records = ExchangeRate.create result.filter{|element| element}
      records_holder.concat new_records
    end
    final_result = records_holder.sort { |element| element.date }.map{|element| element.to_renderable_json(params[:base_currency])}
    
    render json: final_result
  end

  private
  def validate_params
    present_params = params[:base_currency].present? && params[:to].present? && params[:start_date].present? && params[:end_date].present?
    return head 400, error: 'One or multiple required params are missing' unless present_params
    date_diff = params[:end_date].to_date - params[:start_date].to_date
    return head 400, error: 'One or multiple required params are missing' if date_diff < 0
  end
end