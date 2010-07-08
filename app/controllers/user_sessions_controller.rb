class UserSessionsController < ApplicationController


  # GET /user_sessions/new
  # GET /user_sessions/new.xml
  def new
    @user_session = UserSession.new
  end

  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.html { redirect_to(root_url, :notice => 'UserSession was successfully created.') }
        format.xml  { render :xml => root_url, :status => :created, :location => @stock }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => root_url, :status => :unprocessable_entity }
      end
    end
  end

 
  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.xml  { head :ok }
    end
  end
end
