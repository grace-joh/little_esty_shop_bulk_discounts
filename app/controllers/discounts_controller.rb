class DiscountsController < ApplicationController
  before_action :find_merchant, only: [:index, :show, :new, :create, :destroy]
  before_action :find_discount, only: [:show, :destroy]

  def index
  end

  def show
  end

  def new
  end

  def create
    @discount = @merchant.discounts.new(create_discount_params)
    if @discount.save
      redirect_to merchant_discounts_path(@merchant)
      flash[:success] = 'New Discount Created'
    else
      redirect_to new_merchant_discount_path(@merchant)
      flash[:alert] = "Error: #{error_message(@discount.errors)}"
    end
  end

  def destroy
    @discount.destroy
    redirect_to merchant_discounts_path(@merchant)
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_discount
    @discount = Discount.find(params[:id])
  end

  def create_discount_params
    convert_percent_decimal unless params[:percent_integer] == ''
    params.permit(:percent_decimal, :min_quantity)
  end

  def convert_percent_decimal
    params[:percent_decimal] = params[:percent_integer].to_i / 100.to_f
  end
end
