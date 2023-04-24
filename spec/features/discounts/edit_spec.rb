require 'rails_helper'

RSpec.describe 'the Merchant Discounts edit page' do
  describe 'User Story 5' do
    before(:each) do
      delete_data

      @merchant1 = create(:merchant)
      @discount1 = create(:discount, merchant: @merchant1)

      visit edit_merchant_discount_path(@merchant1, @discount1)
    end

    it 'edits an existing discount and displays it on the merchants discounts show page' do
      expect(page).to have_content("Edit Discount ##{@discount1.id}")

      within('#edit-discount-form') do
        expect(page).to have_field('Percent Discount', with: @discount1.decimal_to_percent)
        expect(page).to have_field('Minimum Quantity', with: @discount1.min_quantity)

        fill_in('Percent Discount', with: 32)
        fill_in('Minimum Quantity', with: 111)
        click_button('Update')
      end

      expect(current_path).to eq(merchant_discount_path(@merchant1, @discount1))
      expect(page).to have_content('Discount Updated')
      expect(page).to have_content('32% off 111 items')
    end

    it 'returns an error if percent input is less than 0' do
      within('#edit-discount-form') do
        fill_in 'Percent Discount', with: 0
        fill_in 'Minimum Quantity', with: 100
        click_button 'Update'
      end

      expect(current_path).to eq(edit_merchant_discount_path(@merchant1, @discount1))
      expect(page).to have_content('Error: Percent decimal must be greater than 0')
    end

    it 'returns an error if percent input is greater than 100' do
      within('#edit-discount-form') do
        fill_in 'Percent Discount', with: 120
        fill_in 'Minimum Quantity', with: 100
        click_button 'Update'
      end

      expect(current_path).to eq(edit_merchant_discount_path(@merchant1, @discount1))
      expect(page).to have_content('Error: Percent decimal must be less than or equal to 1')
    end

    it 'returns an error if minimum quantity is not a number' do
      within('#edit-discount-form') do
        fill_in 'Percent Discount', with: 30
        fill_in 'Minimum Quantity', with: 'hundred'
        click_button 'Update'
      end

      expect(current_path).to eq(edit_merchant_discount_path(@merchant1, @discount1))
      expect(page).to have_content('Error: Min quantity is not a number')
    end
  end
end
