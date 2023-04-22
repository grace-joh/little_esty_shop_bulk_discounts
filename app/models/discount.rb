class Discount < ApplicationRecord
  validates_presence_of :percent_decimal,
                        :min_quantity

  belongs_to :merchant
end
