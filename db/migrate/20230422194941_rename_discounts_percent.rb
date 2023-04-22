class RenameDiscountsPercent < ActiveRecord::Migration[5.2]
  def change
    rename_column :discounts, :discount, :percent_decimal
  end
end
