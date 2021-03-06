class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def sales 
    @order = Order.all.where(seller: current_user).order('created_at DESC')
  end

  def purchases
    @order = Order.all.where(buyer: current_user).order('created_at DESC')
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
    @order.listing = @listing 
    @order.seller = @listing.user
    @order.buyer = current_user
    
    #Strip stuff 
    Stripe.api_key = ENV["stripe_api_key"]
    token = params[:stripeToken]

    begin
      charge = Stripe::Charge.create(
        amount: (@order.listing.price * 100).floor, 
        description:  "#{@order.id}-#{@listing.name}-#{@order.buyer.name}", 
        currency: "usd",
        card: token, 
        )
      flash[:notice] = "Thanks for ordering"
    rescue Stripe::CardError => e 
        flash[:error] = e.message 
    end 

    transfer = Stripe::Transfer.create(
      amount: (@listing.price * 95).floor,
      currency: "usd", 
      recipient: current_user.recipient
      )
    

    # customer = Stripe::Customer.create(
    #   email: @order.buyer.email, 
    #   card: params[:stripeToken]
    # )
    # begin 
    #   if !@order.save
    #     flash[:error] = "Your purchase is successful but we have problem storing your order."  #update later
    #   end

    #   charge = Stripe::Charge.create(customer:customer.id, amount: (@order.listing.price * 100).to_i, description:  "#{@order.id}-#{@listing.name}-#{@order.buyer.name}", currency: "usd")
    #   flash[:notice] = "Thanks for ordering"
      
    #   redirect_to listings_path

    # rescue Stripe::CardError => e 
    #     flash[:error] = e.message 
    #     redirect_to listing_orders_path(@listing)
    # end 
     
    respond_to do |format|
      if @order.save
        format.html { redirect_to root_url, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state)
    end
end
