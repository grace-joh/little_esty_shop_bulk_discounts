require 'rails_helper'

RSpec.describe 'the Merchant Discounts show page' do
  before(:each) do
    delete_data

    @merchant1 = create(:merchant)
    @discount1 = create(:discount, merchant: @merchant1)

    visit merchant_discount_path(@merchant1, @discount1)
  end

  describe 'User Story 4' do
    it 'displays the discount details' do
      within('.row') do
        expect(page).to have_content("Discount ##{@discount1.id}")
      end

      within("#discount-details") do
        expect(page).to have_content(@discount1.description)
      end
    end
  end

  describe 'User Story 5' do
    it 'displays a link to edit the discount' do
      expect(page).to have_button('Edit')

      click_button('Edit')

      expect(current_path).to eq(edit_merchant_discount_path(@merchant1, @discount1))
    end
  end
end
