class PortfoliosController < ApplicationController
  
  def list
    @the_user = current_user
    @x = Portfolio.find(:all, :conditions => ["user_id= ?", @the_user.id])
    @y = @x.collect do |a|
      " #{stock_id_to_symbol(a.stock_id)} --> #{a.quantity} "
    end
    respond_to do |format|
      format.html
      format.json {render :json => @y}
    end
  end
  

 
  def buy
    @the_user = current_user
    @the_user_id = @the_user.id
    @exch = params[:exchange]
    @sym = params[:symbol]
    @stock = get_stock(@exch, @sym) 
    @qty = params[:qty]
    @stockholding = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@stock.id)
    puts @stockholding
    puts @the_user.id
    puts @stock.id
    if @stockholding==nil
      @stockholding= Portfolio.new(:user_id => @the_user.id, :stock_id => @stock.id, :quantity => 0)
      @stockholding.save!
      puts "created stockholding?"
    end

    @stockholding.quantity += @qty.to_i
    @stockholding.save!
  
    
  end
  
  def sell
    @the_user = current_user
    @the_user_id = @the_user.id
    @exch = params[:exchange]
    @sym = params[:symbol]
    @stock = get_stock(@exch, @sym) 
    @qty = params[:qty]
    @stockholding = Portfolio.find_by_user_id_and_stock_id(@the_user.id,@stock.id)
    @stockholding.quantity -= @qty.to_i
    @stockholding.save!
  
    
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
  
  def stock_id_to_symbol s
    Stock.find_by_id(s).company
  end
  
  def get_stock exch, sym
    z = Stock.find_by_exchange_and_company(exch,sym)
  end
  
end
