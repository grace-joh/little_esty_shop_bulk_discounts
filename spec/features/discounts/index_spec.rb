require 'rails_helper'

RSpec.describe 'the Merchant Discounts index page' do
  before(:each) do
    delete_data

    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)

    @discount1 = create(:discount, merchant: @merchant1)
    @discount2 = create(:discount, merchant: @merchant1)
    @discount3 = create(:discount, merchant: @merchant1)
    @discount4 = create(:discount, merchant: @merchant2)

    @holidays = HolidayFacade.new.upcoming_holidays(3)

    visit merchant_discounts_path(@merchant1)
  end

  describe 'User Story 1' do
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

  describe 'User Story 2' do
    it 'shows a link to create a new discount' do
      expect(page).to have_link('Create a new discount')

      click_link('Create a new discount')

      expect(current_path).to eq(new_merchant_discount_path(@merchant1))
    end
  end

  describe 'User Story 3' do
    it 'shows a link to create a new discount' do
      within("#discount-#{@discount1.id}") do
        expect(page).to have_button('Delete')

        click_button('Delete')
      end

      expect(current_path).to eq(merchant_discounts_path(@merchant1))
      expect(page).to_not have_content("Discount ##{@discount1.id}")
    end
  end

  describe 'User Story 9' do
    describe 'Holiday list' do
      it 'displays a list of the next three holidays' do
        within('#holidays') do
          expect(page).to have_content('Upcoming Holidays')
          @holidays.each do |holiday|
            expect(page).to have_content(holiday.name)
          end
        end
      end
    end
  end
end
