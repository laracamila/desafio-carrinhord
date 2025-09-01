class Product < ApplicationRecord
  has_many :cart_items, dependent: :restrict_with_error
  has_many :carts, through: :cart_items

  validates_presence_of :name, :price
  validates_numericality_of :price, greater_than_or_equal_to: 0
end
