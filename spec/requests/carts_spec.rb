require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "GET /cart" do
    it "returns an empty cart initially" do
      get '/cart'
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['products']).to eq([])
      expect(body['total_price']).to eq(0.0)
      expect(body['id']).to be_present
    end
  end

  describe "POST /cart" do
    let!(:product) { Product.create!(name: "P1", price: 7.0) }

    context "when adding a new product" do
      it "adds product and returns created payload" do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        expect(response).to have_http_status(:created)

        body = JSON.parse(response.body)
        item = body['products'].find { |p| p['id'] == product.id }
        expect(item['quantity']).to eq(2)
        expect(body['total_price']).to eq(14.0)
      end
    end

    context "when product already exists" do
      it "increments the existing quantity" do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

        body = JSON.parse(response.body)
        item = body['products'].find { |p| p['id'] == product.id }
        expect(item['quantity']).to eq(3)
      end
    end

    context "when quantity is invalid (<= 0)" do
      it "returns 422 with error message" do
        post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body['error']).to match(/Quantidade inválida/i)
      end
    end
  end

  describe "POST /cart/add_item" do
    let!(:product) { Product.create!(name: "P2", price: 9.9) }

    context "when product already in cart" do
      it "increments quantity by provided amount" do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json

        get '/cart'
        body = JSON.parse(response.body)
        item = body['products'].find { |p| p['id'] == product.id }
        expect(item['quantity']).to eq(3)
      end
    end

    context "when adding a new product" do
      it "adds the new product to the cart" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        ids = body['products'].map { |p| p['id'] }
        expect(ids).to include(product.id)
      end
    end

    context "when quantity is invalid (<= 0)" do
      it "returns 422 with error message" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 0 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body['error']).to match(/Quantidade inválida/i)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:product) { Product.create!(name: "P3", price: 5.0) }

    context "when product exists in cart" do
      it "removes the product and returns cart without it" do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        delete "/cart/#{product.id}"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['products']).to eq([])
        expect(body['total_price']).to eq(0.0)
      end
    end

    context "when product does not exist in cart" do
      it "returns 404 with error message" do
        delete "/cart/#{product.id}"
        expect(response).to have_http_status(:not_found)

        body = JSON.parse(response.body)
        expect(body['error']).to match(/Produto não encontrado/i)
      end
    end
  end
end
