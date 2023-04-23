class Discount < ApplicationRecord
  validates :percent_decimal, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  validates :min_quantity, presence: true, numericality: true

  belongs_to :merchant

  def decimal_to_percent
    (percent_decimal * 100).to_i
  end

  def description
    "#{decimal_to_percent}% off #{min_quantity} items"
  end
end
