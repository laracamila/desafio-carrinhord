class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :initialize_total_price, on: :create

  def compute_total_price
    cart_items.sum('cart_items.unit_price * cart_items.quantity')
  end

  def update_total_price!
    new_total = compute_total_price
    update_column(:total_price, new_total) if total_price != new_total
  end

  def mark_as_abandoned
    return false unless inactive_for?(3.hours)
    update!(abandoned_at: Time.current)
  end

  def abandoned?
    abandoned_at.present?
  end

  def remove_if_abandoned
    destroy if abandoned? && (last_interaction_at && last_interaction_at < 7.days.ago)
  end

  def inactive_for?(period)
    reference_time = last_interaction_at || updated_at || created_at
    reference_time < period.ago
  end

  private

  def initialize_total_price
    self.total_price ||= 0
  end
end
