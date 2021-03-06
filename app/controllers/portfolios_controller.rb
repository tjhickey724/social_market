require 'httparty'  # this is creating problems on Heroku!

class PortfoliosController < ApplicationController
  
  def list
    @the_user = current_user
    @member_name = params[:member]
    @authorized = current_user && (!@member_name || current_user.username == @member_name)
    @member_name ||= @the_user.username
    @member = User.find_by_username(@member_name)
    
    @x = Portfolio.find(:all, :conditions => ["user_id= ?", @member.id])
    @dollars = Stock.find_by_exchange_and_company("CURRENCY","$USD");
    @cash = Portfolio.find_by_user_id_and_stock_id(@member.id,@dollars.id)
 
    @y1 = @x.collect do |a|
      sym = stock_id_to_symbol(a.stock_id)
      bid = get_bid_price sym
      ask = get_ask_price sym
      [sym, a.quantity, ask.to_f, bid.to_f, (a.quantity * bid.to_f + 0.5).to_f]
    end

    @y = @y1.reject do |a,b,c,d,e|
      a=="$USD"
    end
    
    @y2 = @y1.collect do |a,b,c,d,e|
      "#{a} -> #{e}"
    end

    @currentvalue = 0
    @y.each do |a,b,c,d,e|
         @currentvalue += e
    end
    @totalvalue = @currentvalue + @cash.quantity
    @member.current_value = @totalvalue
    @member.save
    respond_to do |format|
      format.html
      format.json {render :json => @y1}
    end
  end
  
  def rank
    @the_user = current_user
    @the_rank = User.count(:conditions => ["current_value >= ?", @the_user.current_value])
    @membership = User.count(:all)
    respond_to do |format|
      format.html
      format.json {render :json => [ @the_rank, @membership]}
    end
  end
  
   def leaders
    @the_user = current_user
    @the_rank = User.count(:conditions => ["current_value >= ?", @the_user.current_value])
    @leaders = User.find(:all, :limit => 10, :order => "current_value desc")
    @membership = User.count(:all)
    @leaders_data = @leaders.collect do |a|
      [a.username, a.current_value, a.updated_at, a.created_at]
    end
    respond_to do |format|
      format.html
      format.json {render :json => [ @the_rank, @membership, @leaders_data]}
    end
  end
  
    
   def local_leaders
     # lat1 < lat < lat2   and lon1 < lon < lon2 defines the "rectangle" of interest
    @lat1 = params[:lat1]
    @lat2 = params[:lat2]
    @lon1 = params[:lon1]
    @lon2 = params[:lon2]
    @lat = current_user.lattitude || 41123456
    @lon = current_user.longitude || -71234567
    
    @the_user = current_user
    @the_rank = User.count(:conditions => 
        ["current_value >= ? and (? <= lattitude) and (lattitude <= ?) and (? <= longitude) and (longitude <= ?)", 
          @the_user.current_value,@lat1,@lat2,@lon1,@lon2])
    @leaders = User.find(:all, :limit => 10, :order => "current_value desc",
          :conditions =>  ["(? < lattitude) and (lattitude < ?) and (? < longitude) and (longitude < ?)", 
          @lat1,@lat2,@lon1,@lon2])
    @membership = User.count(:all,
          :conditions =>  ["(? <= lattitude) and (lattitude <= ?) and (? <= longitude) and (longitude <= ?)", 
          @lat1,@lat2,@lon1,@lon2])
    @leaders_data = @leaders.collect do |a|
      [a.username, a.current_value, a.updated_at, a.created_at, the_dist(a.lattitude,a.longitude,@lat,@lon)]
    end
    respond_to do |format|
      format.html
      format.json {render :json => [ @the_rank, @membership, @leaders_data]}
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
  
  def remove
    @the_user = current_user
    @sym = params[:symbol]
    @stock = Stock.find_by_company(@sym)
    @portf = Portfolio.find_by_user_id_and_stock_id(@the_user.id, @stock.id)
    @bid = get_bid_price @sym
    @qty = @portf.quantity
    sell_stock(@portf, @the_user.id,@stock.id,@qty, @bid)
    @portf.destroy
    flash[:notice] = "You sold all #{@qty} shares of #{@sym} at $#{@bid}/share"
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
  
  def the_dist(lat1,lon1,lat2,lon2) 
    scale = 25000/360.0/1000000.0  # converstion from degrees to miles on the equator
    vdist = (lat1 - lat2)*scale
    hdist = (lon1-lon2)*Math.cos(lat2)*scale
    Math.sqrt(vdist*vdist+ hdist*hdist)
  end
  
  
end
