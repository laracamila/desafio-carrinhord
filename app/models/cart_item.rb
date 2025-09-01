class CartItem < ApplicationRecord
  belongs_to :cart, touch: true
  belongs_to :product

  validates :cart_id, :product_id, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :product_id, uniqueness: { scope: :cart_id, message: "já está no carrinho" }

  before_create :set_unit_price
  after_commit :update_cart_after_item_change, on: [:create, :update, :destroy]

  def unit_price
    self[:unit_price] || product.price
  end

  def product_total_price
    unit_price * quantity
  end

  private

  def set_unit_price
    self[:unit_price] = product.price
  end

  def update_cart_after_item_change
    return if destroyed_by_association || cart.destroyed?
    cart.update_total_price!
    cart.update_column(:last_interaction_at, Time.current)
  end
end
