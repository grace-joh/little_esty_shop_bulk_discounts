class DiscountsController < ApplicationController
  before_action :find_merchant, only: [:index]

  def index
  end

  def show
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
