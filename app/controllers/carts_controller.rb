class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: [:create, :add_item]

  def show
    render json: cart_response(@cart)
  end

  def create
    quantity = require_positive_quantity or return

    @cart.with_lock do
      item = @cart.cart_items.find_or_initialize_by(product: @product)
      item.quantity = (item.quantity || 0) + quantity

      unless item.save
        return render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    render json: cart_response(@cart), status: :created
  end

  # POST /cart/add_item – incrementa a quantidade do produto no carrinho
  def add_item
    quantity = require_positive_quantity or return

    @cart.with_lock do
      item = @cart.cart_items.find_or_initialize_by(product: @product)
      item.quantity = (item.quantity || 0) + quantity

      unless item.save
        return render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    render json: cart_response(@cart)
  end

  def destroy
    product_id = params[:product_id].to_i
    item = @cart.cart_items.find_by(product_id: product_id)

    if item
      item.destroy
      render json: cart_response(@cart)
    else
      render json: { error: "Produto não encontrado no carrinho" }, status: :not_found
    end
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) if session[:cart_id]
    @cart ||= Cart.last || Cart.create!
    session[:cart_id] = @cart.id
  end

  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Produto não encontrado" }, status: :not_found
  end

  def require_positive_quantity
    q = params.require(:quantity).to_i
    if q > 0
      q
    else
      render json: { error: "Quantidade inválida (precisa ser > 0)" }, status: :unprocessable_entity
      nil
    end
  end

  def cart_response(cart)
    cart = Cart.includes(cart_items: :product).find(cart.id) # evita N+1
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id:         item.product.id,
          name:       item.product.name,
          quantity:   item.quantity,
          unit_price: item.unit_price.to_f,
          total_price:item.product_total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
