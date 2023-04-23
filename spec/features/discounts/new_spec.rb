require 'rails_helper'

RSpec.describe 'the Merchant Discounts new page' do
  describe 'User Story 2' do
    before(:each) do
      visit new_merchant_discount_path(merchant1)
    end

    it 'displays a form to create a new discount' do
      expect(page).to have_link('Create a new discount')
      expect(page).to have_field('Percent discount')
      expect(page).to have_field('Minimum quantity')
    end

    it 'creates a new discount and displays it on the merchants discounts index page' do
      fill_in('Percent discount', with: 32)
      fill_in('Minimum quantity', with: 111)
      click_link('Submit')

      expect(current_path).to eq(merchant_discounts_path(merchant1))
      expect(page).to have_content('32% off 111 items')
    end
  end
end
