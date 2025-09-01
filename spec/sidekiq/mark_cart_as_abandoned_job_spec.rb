require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  subject(:job) { described_class.new }

  describe '#perform' do
    context 'when marking carts as abandoned' do
      let!(:recent_cart)            { create(:cart) }
      let!(:inactive_cart)          { create(:cart, last_interaction_at: 4.hours.ago) }
      let!(:already_abandoned_cart) { create(:cart, :abandoned) }

      before { inactive_cart.update_column(:updated_at, 4.hours.ago) }

      it 'marks carts with 3h+ inactivity' do
        expect { job.perform }.to change { inactive_cart.reload.abandoned_at }.from(nil)
      end

      it 'does not mark recent carts' do
        expect { job.perform }.not_to change { recent_cart.reload.abandoned_at }
      end

      it 'does not re-mark already abandoned carts' do
        expect { job.perform }.not_to change { already_abandoned_cart.reload.abandoned_at }
      end
    end

    context 'when removing old abandoned carts' do
      let!(:recent_abandoned) { create(:cart, :abandoned) }
      let!(:old_abandoned)    { create(:cart, :old_abandoned) }

      it 'removes carts abandoned for 7+ days' do
        expect { job.perform }.to change(Cart, :count).by(-1)
        expect { old_abandoned.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'keeps recently abandoned carts' do
        expect { job.perform }.not_to change { recent_abandoned.reload.abandoned_at }
      end
    end
  end
end
