require 'rails_helper'

describe Discount do
  describe 'validations' do
    it { should validate_presence_of :percent_decimal }
    it { should validate_presence_of :min_quantity }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
  end
end
