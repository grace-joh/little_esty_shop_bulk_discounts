require 'rails_helper'

describe Discount do
  describe 'validations' do
    it { should validate_presence_of :percent_decimal }
    it { should validate_presence_of :min_quantity }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
  end

  describe 'instance methods' do
    before(:all) do
      delete_data

      @discount1 = create(:discount, percent_decimal: 0.0, min_quantity: 10)
      @discount2 = create(:discount, percent_decimal: 0.54, min_quantity: 20)
      @discount3 = create(:discount, percent_decimal: 1.0, min_quantity: 30)
    end

    describe '#decimal_to_percent' do
      it 'returns the integer percent value of its decimal' do
        expect(@discount1.decimal_to_percent).to eq(0)
        expect(@discount2.decimal_to_percent).to eq(54)
        expect(@discount3.decimal_to_percent).to eq(100)
      end
    end

    describe '#description' do
      it 'returns a string of a discounts percent off a min quantity of items' do
        expect(@discount1.description).to eq("#{@discount1.decimal_to_percent}% off #{@discount1.min_quantity} items")
        expect(@discount2.description).to eq("#{@discount2.decimal_to_percent}% off #{@discount2.min_quantity} items")
        expect(@discount3.description).to eq("#{@discount3.decimal_to_percent}% off #{@discount3.min_quantity} items")
      end
    end
  end
end
