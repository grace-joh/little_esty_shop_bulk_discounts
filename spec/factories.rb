FactoryBot.define do
  factory :customer do
    sequence(:id)
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end

  factory :invoice do
    sequence(:id)
    status { Faker::Number.between(from: 0, to: 2) }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    association :customer
  end

  factory :merchant do
    sequence(:id)
    name { Faker::Company.name }
    status { Faker::Number.between(from: 0, to: 1) }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end

  factory :item do
    sequence(:id)
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    unit_price { Faker::Number.between(from: 1, to: 1000) }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    association :merchant
  end

  factory :transaction do
    sequence(:id)
    credit_card_number { Faker::Business.credit_card_number }
    result { Faker::Number.between(from: 0, to: 1) }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    association :invoice
  end

  factory :invoice_item do
    sequence(:id)
    quantity { Faker::Number.between(from: 1, to: 5) }
    unit_price { Faker::Number.between(from: 1, to: 1000) }
    status { Faker::Number.between(from: 0, to: 2) }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    association :invoice, :item
  end

  factory :discount do
    sequence(:id)
    percent_decimal { Faker::Number.between(from: 0.1, to: 0.9).round(2) }
    min_quantity { Faker::Number.between(from: 5, to: 10) }

    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    association :merchant
  end
end
