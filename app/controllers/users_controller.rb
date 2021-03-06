class UsersController < ApplicationController
  #  before_filter :authorize
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.current_value = 100000;
    @user.lattitude = 42367000
    @user.longitude = -71259000
    Portfolio.new(:user_id => @user.id, :stock_id => 1, :quantity => 100000).save! ;

    respond_to do |format|
      if @user.save
        flash[:notice] = "Registration successful."
        @user.current_value = 100000;
        Portfolio.new(:user_id => @user.id, :stock_id => 1, :quantity => 100000).save! ;
        @user.save!
        format.html { redirect_to("/", :notice => 'You are now registered for the Social Market Game!') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "Successfully updated user."
        format.html { redirect_to(root_url, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  def set_location
    @user = User.find_by_username(params[:u])
    @user.lattitude = params[:lat]
    @user.longitude = params[:lon]
    @user.save!

  end
  
  def get_locations
    @users = User.find(:all)
    @userlocs  = @users.collect do |u|
      [u.lattitude, u.longitude, u.username]
     # {:lattitude => u.lattitude, :longitude => u.longitude, :username => u.username}
    end
    respond_to do |format|
      format.html
      format.xml {render :xml => @userlocs}
      format.json {render :json => @userlocs}
    end
  end
end
