require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end

  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end

  describe "instance methods" do
    it "total_revenue" do
      merchant1 = Merchant.create!(name: 'Hair Care')
      item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant1.id, status: 1)
      item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: merchant1.id)
      customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      invoice_1 = Invoice.create!(customer_id: customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 9, unit_price: 10, status: 2)
      InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(invoice_1.total_revenue).to eq(1.00)
    end

    before(:each) do
      delete_data

      @merchant1 = create(:merchant)
      @item1 = create(:item, unit_price: 1, merchant: @merchant1)
      @item2 = create(:item, unit_price: 1, merchant: @merchant1)
      @item3 = create(:item, unit_price: 1, merchant: @merchant1)

      @merchant2 = create(:merchant)
      @item5 = create(:item, unit_price: 1, merchant: @merchant2)

      @customer1 = create(:customer)
      @invoice1 = create(:invoice, customer: @customer1)
    end

    describe '#total_discounts and #total_revenue' do
      it 'counts no discounts if discounts do not exist' do
        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00
        @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40) # 12.00
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00

        expect(@invoice1.total_discounts).to eq(0)
        expect(@invoice1.total_revenue_with_discounts).to eq(19.90)
      end

      it 'counts no discounts if invoice items do not meet the discount minimum quantity' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 100, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 100, merchant: @merchant2)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00
        @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40) # 12.00
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00

        expect(@invoice1.total_discounts).to eq(0)
        expect(@invoice1.total_revenue_with_discounts).to eq(19.90)
      end

      it 'only counts discounts where the minimum quantity is met and do not affect other merchants' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 100, merchant: @merchant2)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00 - 0.20 = 1.80
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00

        expect(@invoice1.total_discounts).to eq(0.20)
        expect(@invoice1.total_revenue_with_discounts).to eq(7.70)
      end

      it 'counts the greater discount if item meets min quantity for multiple discounts and do not affect other merchants' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 30, merchant: @merchant1) # *
        @discount3 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant2)
        @discount3 = create(:discount, percent_decimal: 0.40, min_quantity: 5, merchant: @merchant2) # *

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 30, unit_price: 20) # 6.00 - 3.00 = 3.00
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00 - 2.00 = 3.00

        expect(@invoice1.total_discounts).to eq(5.00)
        expect(@invoice1.total_revenue_with_discounts).to eq(6.90)
      end
    end

    describe '#total_revenue_for' do
      it 'returns the total revenue from an invoice for the specified merchant (not including discounts)' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 30, merchant: @merchant1)
        # does not qualify for any merchant1 discounts  = 0.90
        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10)
        # qualifies for only discount1 = 1.80 (not 2.00)
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20)
        # qualifies for both discount1 and discount2 so only discount2 should apply = 6 (not 12)
        @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40)
        # item for different merchant shouldnt show on revenue
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50)

        expect(@invoice1.total_revenue_for(@merchant1.id)).to eq(14.90)
        expect(@invoice1.total_revenue_for(@merchant2.id)).to eq(5.00)
      end
    end

    describe '#total_discount_for and #total_discounted_revenue' do
      it 'counts no discounts if discounts do not exist' do
        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00
        @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40) # 12.00
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00

        expect(@invoice1.total_discount_from(@merchant1.id)).to eq(0)
        expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(14.90)

        expect(@invoice1.total_discount_from(@merchant2.id)).to eq(0)
        expect(@invoice1.total_discounted_revenue(@merchant2.id)).to eq(5.00)
      end

      it 'counts no discounts if invoice items do not meet the discount minimum quantity' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 100, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 100, merchant: @merchant1)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00
        @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40) # 12.00
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00

        expect(@invoice1.total_discount_from(@merchant1.id)).to eq(0)
        expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(14.90)

        expect(@invoice1.total_discount_from(@merchant2.id)).to eq(0)
        expect(@invoice1.total_discounted_revenue(@merchant2.id)).to eq(5.00)
      end

      it 'only counts discounts where the minimum quantity is met' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00 - 0.20 = 1.80

        expect(@invoice1.total_discount_from(@merchant1.id)).to eq(0.20)
        expect(@invoice1.total_discounted_revenue(@merchant1.id).round(2)).to eq(2.70)
        # expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(2.6999999999999997)
      end

      it 'counts the greater discount if item meets min quantity for multiple discounts' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 30, merchant: @merchant1)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 30, unit_price: 20) # 6.00 - 3.00 = 3.00

        expect(@invoice1.total_discount_from(@merchant1.id)).to eq(3.00)
        expect(@invoice1.total_discounted_revenue(@merchant1.id).round(2)).to eq(3.90)
        # expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(3.9000000000000004)
      end

      it 'counts the greater discount regardless of minimum quantity' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1) # doesnt apply ever
        @discount2 = create(:discount, percent_decimal: 0.50, min_quantity: 5, merchant: @merchant1)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90 - 0.45 = 0.45
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 30, unit_price: 20) # 6.00 - 3.00 = 3.00

        expect(@invoice1.total_discount_from(@merchant1.id)).to eq(3.45)
        expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(3.45)
      end

      it 'applies discounts to items only from the specified merchant and does not affect another merchants revenue' do
        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)
        @discount2 = create(:discount, percent_decimal: 0.40, min_quantity: 10, merchant: @merchant2)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10) # 0.90
        @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20) # 2.00 - 0.20 = 1.80
        @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40) # 12.00 - 1.20 = 10.80
        @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50) # 5.00 - 2.00 = 3.00

        expect(@invoice1.total_discount_from(@merchant1.id).round(2)).to eq(1.40)
        # expect(@invoice1.total_discount_from(@merchant1.id)).to eq(1.4000000000000001)
        expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(13.50)

        expect(@invoice1.total_discount_from(@merchant2.id)).to eq(2.00)
        expect(@invoice1.total_discounted_revenue(@merchant2.id)).to eq(3.00)
      end

      it 'applies a merchants discount on different items on different invoices' do
        @invoice2 = create(:invoice, customer: @customer1)

        @discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)

        @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 10, unit_price: 10) # 1.00 - 0.10 = 0.90
        @ii2 = create(:invoice_item, invoice: @invoice2, item: @item2, quantity: 10, unit_price: 20) # 2.00 - 0.20 = 1.80

        expect(@invoice1.total_discount_from(@merchant1.id)).to eq(0.10)
        expect(@invoice1.total_discounted_revenue(@merchant1.id)).to eq(0.90)

        expect(@invoice2.total_discount_from(@merchant1.id)).to eq(0.20)
        expect(@invoice2.total_discounted_revenue(@merchant1.id)).to eq(1.80)
      end
    end
  end
end
