require 'rails_helper'

RSpec.describe 'the Merchant Discounts new page' do
  describe 'User Story 2' do
    before(:each) do
      delete_data

      @merchant1 = create(:merchant)
      visit new_merchant_discount_path(@merchant1)
    end

    it 'creates a new discount and displays it on the merchants discounts index page' do
      expect(page).to have_content('Create Discount')

      within('#new-discount-form') do
        fill_in('Percent Discount', with: 32)
        fill_in('Minimum Quantity', with: 111)
        click_button('Create')
      end

      expect(current_path).to eq(merchant_discounts_path(@merchant1))
      expect(page).to have_content('New Discount Created')
      expect(page).to have_content("Discount ##{Discount.last.id} - #{Discount.last.description}")
    end

    it 'returns an error if input is blank' do
      within('#new-discount-form') do
        click_button 'Create'
      end

      expect(current_path).to eq(new_merchant_discount_path(@merchant1))
      expect(page).to have_content("Percent decimal can't be blank")
      expect(page).to have_content("Min quantity can't be blank")
    end

    it 'returns an error if percent input is less than 0' do
      within('#new-discount-form') do
        fill_in 'Percent Discount', with: 0
        fill_in 'Minimum Quantity', with: 100
        click_button 'Create'
      end

      expect(current_path).to eq(new_merchant_discount_path(@merchant1))
      expect(page).to have_content('Error: Percent decimal must be greater than 0')
    end

    it 'returns an error if percent input is greater than 100' do
      within('#new-discount-form') do
        fill_in 'Percent Discount', with: 120
        fill_in 'Minimum Quantity', with: 100
        click_button 'Create'
      end

      expect(current_path).to eq(new_merchant_discount_path(@merchant1))
      expect(page).to have_content('Error: Percent decimal must be less than or equal to 1')
    end

    it 'returns an error if minimum quantity is not a number' do
      within('#new-discount-form') do
        fill_in 'Percent Discount', with: 30
        fill_in 'Minimum Quantity', with: 'hundred'
        click_button 'Create'
      end

      expect(current_path).to eq(new_merchant_discount_path(@merchant1))
      expect(page).to have_content('Error: Min quantity is not a number')
    end
  end
end
