FactoryBot.define do
  factory :cart_item do
    cart
    product
    quantity   { 1 }
    unit_price { product.price }
  end
end
