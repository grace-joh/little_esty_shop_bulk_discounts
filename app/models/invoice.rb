class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price / 100 * quantity")
  end

  def total_discounts
    invoice_items.joins(item: { merchant: :discounts })
                 .where("invoice_items.quantity >= discounts.min_quantity")
                 .group('invoice_items.id')
                 .select("invoice_items.*,
                        MAX(invoice_items.quantity * (invoice_items.unit_price / 100) *
                          CASE WHEN invoice_items.quantity >= discounts.min_quantity THEN discounts.percent_decimal
                               ELSE 0
                          end) AS discount")
                 .sum(&:discount)
  end

  def total_revenue_with_discounts
    total_revenue - total_discounts
  end

  def total_revenue_for(merchant_id)
    invoice_items.joins(item: :merchant)
                 .where("items.merchant_id = #{merchant_id}")
                 .sum('invoice_items.unit_price / 100 * invoice_items.quantity')
  end

  def total_discount_from(merchant_id)
    # require 'pry'; binding.pry
    invoice_items.joins(item: { merchant: :discounts })
                 .where("items.merchant_id = #{merchant_id} AND discounts.merchant_id = #{merchant_id}")
                 .group('invoice_items.id')
                 .select("invoice_items.*,
                        MAX(invoice_items.quantity * (invoice_items.unit_price / 100) *
                          CASE WHEN invoice_items.quantity >= discounts.min_quantity THEN discounts.percent_decimal
                               ELSE 0
                          end) AS discount")
                 .sum(&:discount)
  end

  def total_discounted_revenue(merchant_id)
    (total_revenue_for(merchant_id) - total_discount_from(merchant_id))
  end
end
