Customer.destroy_all
Merchant.destroy_all
Item.destroy_all
Invoice.destroy_all
Transaction.destroy_all
InvoiceItem.destroy_all
Discount.destroy_all

system('rake import:all')
