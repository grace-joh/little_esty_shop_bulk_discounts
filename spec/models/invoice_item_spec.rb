require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1)
    end
    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end
  end

  describe 'instance methods' do
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

      @ii1 = create(:invoice_item, invoice: @invoice1, item: @item1, quantity: 9, unit_price: 10)
      @ii2 = create(:invoice_item, invoice: @invoice1, item: @item2, quantity: 10, unit_price: 20)
      @ii3 = create(:invoice_item, invoice: @invoice1, item: @item3, quantity: 30, unit_price: 40)
      @ii4 = create(:invoice_item, invoice: @invoice1, item: @item5, quantity: 10, unit_price: 50)
    end

    describe 'applied_discount' do
      it 'returns the discount applicable to the invoice item' do
        discount1 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)
        discount2 = create(:discount, percent_decimal: 0.10, min_quantity: 5, merchant: @merchant2)

        expect(@ii2.applied_discount).to eq(discount1)
        expect(@ii3.applied_discount).to eq(discount1)
        expect(@ii4.applied_discount).to eq(discount2)
      end

      it 'returns the biggest discount applicable to the invoice item' do
        discount1 = create(:discount, percent_decimal: 0.30, min_quantity: 10, merchant: @merchant1)
        discount2 = create(:discount, percent_decimal: 0.10, min_quantity: 10, merchant: @merchant1)

        expect(@ii2.applied_discount).to eq(discount1)
      end

      it 'returns nil if the invoice item does not meet minimum quantity for any discount' do
        discount1 = create(:discount, percent_decimal: 0.30, min_quantity: 10, merchant: @merchant1)

        expect(@ii1.applied_discount).to eq(nil)
      end

      it 'returns nil if there is no discounts for that items merchant exists' do
        expect(@ii1.applied_discount).to eq(nil)
        expect(@ii4.applied_discount).to eq(nil)
      end
    end
  end
end
