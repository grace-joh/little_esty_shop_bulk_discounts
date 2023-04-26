require "rails_helper"

RSpec.describe Holiday do
  before(:all) do
    attrs = {
      localName: "Leo's Birthday",
      date: '2021-10-13'
    }

    @holiday = Holiday.new(attrs)
  end

  describe 'initialize' do
    it 'exists' do
      expect(@holiday).to be_a Holiday
      expect(@holiday.name).to eq("Leo's Birthday")
      expect(@holiday.date).to eq('2021-10-13')
    end
  end
end
