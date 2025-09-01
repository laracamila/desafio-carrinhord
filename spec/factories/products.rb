FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { BigDecimal('19.90') }

    trait :premium do
      price { BigDecimal('149.90') }
    end
  end
end
