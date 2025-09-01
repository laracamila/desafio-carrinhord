FactoryBot.define do
  factory :cart do
    total_price { 0 }

    trait :abandoned do
      abandoned_at { 4.hours.ago }
    end

    trait :old_abandoned do
      abandoned_at { 8.days.ago }
    end

    factory :shopping_cart, parent: :cart
  end
end
