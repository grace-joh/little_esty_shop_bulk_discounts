class DiscountsController < ApplicationController
  before_action :find_merchant
  before_action :find_discount, only: [:show, :edit, :update, :destroy]

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

  def edit
  end

  def update
    if @discount.update(update_discount_params)
      redirect_to merchant_discount_path(@merchant, @discount)
      flash[:success] = 'Discount Updated'
    else
      redirect_to edit_merchant_discount_path(@merchant, @discount)
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
    convert_percent_decimal
    params.permit(:percent_decimal, :min_quantity)
  end

  def update_discount_params
    convert_percent_decimal
    params.require(:discount).permit(:percent_decimal, :min_quantity)
  end

  def convert_percent_decimal
    params[:discount][:percent_decimal] = (params[:discount][:percent_integer].to_i / 100.to_f) unless params[:percent_integer] == ''
  end
end
