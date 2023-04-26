namespace :create do
  task :discounts_csv => :environment do
    rows = FactoryBot.create_list(:discount, 100)

    CSV.open('db/data/discounts.csv', 'w') do |csv|
      csv << ['id', 'percent_decimal', 'min_quantity', 'merchant_id', 'created_at', 'updated_at']

      rows.each do |row|
        merchant_id = Random.new
        array = [row.id, row.percent_decimal, row.min_quantity, merchant_id.rand(100), row.created_at, row.updated_at]
        csv << array.to_csv.split(',')
      end
    end
  end
end
