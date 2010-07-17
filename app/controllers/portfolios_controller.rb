require 'HTTParty'

class PortfoliosController < ApplicationController
  
  def list
    @the_user = current_user
    @x = Portfolio.find(:all, :conditions => ["user_id= ?", @the_user.id])
    @dollars = Stock.find_by_exchange_and_company("CURRENCY","$USD");
    @cash = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@dollars.id)
    puts @x.inspect
    if (params[:clean] == "yes")
      @x = @x.reject do |a|
        if (a.quantity ==0)
          a.destroy
          true
        else
          false
        end
      end
    end
    @y1 = @x.collect do |a|
      sym = stock_id_to_symbol(a.stock_id)
      bid = get_bid_price sym
      ask = get_ask_price sym
      [sym, a.quantity, ask, bid, (a.quantity * bid.to_f + 0.5).to_i]
    end

    @y = @y1.reject do |a,b,c,d,e|
      a=="$USD"
    end

    @currentvalue = 0
    @y.each do |a,b,c,d,e|
         @currentvalue += e
    end
    @totalvalue = @currentvalue + @cash.quantity
    @the_user.current_value = @totalvalue
    @the_user.save
    respond_to do |format|
      format.html
      format.json {render :json => @y1}
    end
  end
  
  def add
    @the_user = current_user
    @sym = params[:symbol]
    @stock = Stock.find_by_company(@sym)
    @portf = Portfolio.new(:user_id => @the_user.id, :stock_id => @stock.id, :quantity => 0)
    @portf.save!
    flash[:notice] = "You've added #{@sym} to your portfolio and can now buy or sell that stock"
    redirect_to "/portfolio/list"
  end
 
 
  def buy
    @the_user = current_user
    @the_user_id = @the_user.id
    @exch = params[:exchange]
    @sym = params[:symbol]
    @quote = get_stock_quote(  @sym)
    @ask = ( @quote[1]).to_f
    @stock = get_stock(@exch, @sym) 
    @qty = params[:qty]
    @stockholding = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@stock.id)
    if (@stockholding==nil)
      @stockholding = Portfolio.new(:user_id => @the_user.id, :stock_id => @stock.id, :quantity => 0)
      @stockholding.save
    end
    buy_stock(@stockholding, @the_user.id, @stock.id,@qty, @ask)
    flash[:notice] = "You bought #{@qty} shares of #{@sym} at $#{@ask}/share"
    redirect_to "/portfolio/list"
  end
  
  def sell
    @the_user = current_user
    @the_user_id = @the_user.id
    @exch = params[:exchange]
    @sym = params[:symbol]
    @quote = get_stock_quote(  @sym)
    @bid = ( @quote[2]).to_f
    @stock = get_stock(@exch, @sym) 
    @qty = params[:qty]
    @stockholding = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@stock.id)
    sell_stock(@stockholding, @the_user.id,@stock.id,@qty, @bid)
    flash[:notice] = "You sold #{@qty} shares of #{@sym} at $#{@bid}/share"
    redirect_to "/portfolio/list"
    
  end
  
  
  
  # GET /portfolios
  # GET /portfolios.xml
  def index
    @portfolios = Portfolio.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portfolios }
    end
  end

  # GET /portfolios/1
  # GET /portfolios/1.xml
  def show
    @portfolio = Portfolio.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portfolio }
    end
  end

  # GET /portfolios/new
  # GET /portfolios/new.xml
  def new
    @portfolio = Portfolio.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portfolio }
    end
  end

  # GET /portfolios/1/edit
  def edit
    @portfolio = Portfolio.find(params[:id])
  end

  # POST /portfolios
  # POST /portfolios.xml
  def create
    @portfolio = Portfolio.new(params[:portfolio])

    respond_to do |format|
      if @portfolio.save
        format.html { redirect_to(@portfolio, :notice => 'Portfolio was successfully created.') }
        format.xml  { render :xml => @portfolio, :status => :created, :location => @portfolio }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portfolio.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portfolios/1
  # PUT /portfolios/1.xml
  def update
    @portfolio = Portfolio.find(params[:id])

    respond_to do |format|
      if @portfolio.update_attributes(params[:portfolio])
        format.html { redirect_to(@portfolio, :notice => 'Portfolio was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portfolio.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portfolios/1
  # DELETE /portfolios/1.xml
  def destroy
    @portfolio = Portfolio.find(params[:id])
    @portfolio.destroy

    respond_to do |format|
      format.html { redirect_to(portfolios_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  
  def sell_stock stockholding, user_id, stock_id, qty, bid
    stockholding.quantity -= @qty.to_i
    stockholding.save!
    @dollars = Stock.find_by_exchange_and_company("CURRENCY","$USD");
    @cash = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@dollars.id)
    if (@cash==nil)
      x = Portfolio.new(:user_id => @the_user.id, :stock_id => @cash.id,:quantity => 100000)
    end
    @cash.quantity += ((qty.to_i) * bid+0.5).to_i
    @cash.save!
  end
  
  def buy_stock stockholding, user_id, stock_id, qty, ask
    stockholding.quantity += @qty.to_i
    stockholding.save!
    @dollars = Stock.find_by_exchange_and_company("CURRENCY","$USD");
    @cash = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@dollars.id)
    if (@cash==nil)
      @cash = Portfolio.new(:user_id => @the_user.id, :stock_id => @dollars.id,:quantity => 100000)
    end
    puts "updating cash value"
    puts @cash.quantity
    puts (qty.to_i)*ask
    @cash.quantity -= (((qty.to_i) * ask) + 0.5).to_i
    puts @cash.quantity
    
    @cash.save!
    
  end
  
  def stock_id_to_symbol s
    Stock.find_by_id(s).company
  end
  
  def get_stock exch, sym
    z = Stock.find_by_exchange_and_company(exch,sym)
  end
  
  def get_stock_quote sym
    y = Stock.find_by_company(sym)
    if ((y.bid != nil) && (y.updated_at + 100.hour > Time.now))
      [sym, y.ask, y.bid]
    else
      x = StockQuote.get('http://finance.yahoo.com/d/quotes.csv?s='+sym+'&f=sab').split(",")
      y.ask = x[1].to_f
      y.bid = x[2].to_f
      y.save
      [sym, y.ask, y.bid]
    end
  end
  
   
  def get_bid_price sym
    if (sym == '$USD')
      1
    else
      x =  get_stock_quote(sym)
      x[2].to_f
    end

  end
  
  def get_ask_price sym
    if (sym == '$USD')
      1
    else
      x=get_stock_quote(sym)
      x[1].to_f
    end
  end
  
  class StockQuote
    include HTTParty
  end
  
  
  
end
