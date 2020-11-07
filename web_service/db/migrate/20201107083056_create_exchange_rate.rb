class CreateExchangeRate < ActiveRecord::Migration[6.0]
  def change
    create_table :exchange_rates do |t|
      t.float     :rate
      t.string    :from
      t.string    :to
      t.date      :date
      t.timestamps
    end
  end
end
