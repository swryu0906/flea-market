 class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_listing, only: [:new, :create]
  before_action :check_purchasable, only: [:new, :create]
  def sales
    @orders = Order.where(seller: current_user).order("created_at DESC")
  end

  def purchases
    @orders = Order.where(buyer: current_user).order("created_at DESC")
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all.order("created_at DESC")
  end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @order.listing_id = @listing.id
    @order.seller_id = @listing.user_id
    @order.buyer_id = current_user.id
    @order.listing.sold = true

    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    token = params[:stripeToken]

    begin
      charge = Stripe::Charge.create(
        amount: (@listing.price * 100).floor,
        currency: "usd",
        source: token,
        description: "Charge for #{current_user.email}"
      )
      flash[:notice] = "Thanks for ordering!"
    rescue Stripe::CardError => e
      # This card has been declined
      flash[:danger] = e.message
    end

    respond_to do |format|
      if @order.save
        @order.listing.save
        format.html { redirect_to purchases_path }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def set_listing
      @listing = Listing.find(params[:listing_id])
    end

    def check_purchasable
      if (@listing.sold) || (@listing.user == current_user)
        redirect_to root_url  
        flash[:error] = "You can't purchase this item!"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state, :zip)
    end
end
