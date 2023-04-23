class Discount < ApplicationRecord
  validates_presence_of :percent_decimal,
                        :min_quantity

  belongs_to :merchant

  def decimal_to_percent
    (percent_decimal * 100).to_i
  end

  def description
    "#{decimal_to_percent}% off #{min_quantity} items"
  end
end
