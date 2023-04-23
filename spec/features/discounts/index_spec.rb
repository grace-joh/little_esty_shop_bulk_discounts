require 'rails_helper'

RSpec.describe 'the Merchant Discounts show page' do
  describe 'User Story 1' do
    before(:each) do
      delete_data

      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)

      @discount1 = create(:discount, merchant: @merchant1)
      @discount2 = create(:discount, merchant: @merchant1)
      @discount3 = create(:discount, merchant: @merchant1)
      @discount4 = create(:discount, merchant: @merchant2)

      visit merchant_discounts_path(@merchant1)
    end

    it 'shows a list of all the merchants discounts' do
      expect(page).to have_content('My Discounts')
      expect(page).to have_content("Discount ##{@discount1.id} - #{@discount1.description}")
      expect(page).to have_content("Discount ##{@discount2.id} - #{@discount2.description}")
      expect(page).to have_content("Discount ##{@discount3.id} - #{@discount3.description}")
      expect(page).to_not have_content("Discount ##{@discount4.id} - #{@discount4.description}")
    end

    it 'links each discount to its show page' do
      @merchant1.discounts.each do |discount|
        visit merchant_discounts_path(@merchant1)

        expect(page).to have_link("Discount ##{discount.id}")

        click_link("Discount ##{discount.id}")

        expect(current_path).to eq(merchant_discount_path(@merchant1, discount))
      end
    end
  end
end
