class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    abandoned_carts = Cart.where(abandoned_at: nil)
                         .where('updated_at < ?', 3.hours.ago)

    abandoned_carts.find_each do |cart|
      cart.mark_as_abandoned
      Rails.logger.info "Carrinho #{cart.id} marcado como abandonado"
    end
  end

  def remove_old_abandoned_carts
    old_abandoned_carts = Cart.where('abandoned_at < ?', 7.days.ago)

    old_abandoned_carts.find_each do |cart|
      cart.destroy
      Rails.logger.info "Carrinho #{cart.id} removido (abandonado há mais de 7 dias)"
    end
  end
end
