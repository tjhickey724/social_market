# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #before_filter :authorize, :except =>:user_sesssions
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :current_user, :current_username
  
  protected
   def authorize
     unless current_user
       flash[:notice] = "Please log in"
       redirect_to "/login"
     end
   end
  
  private
  
  def current_user_session
    if (params[:u] && params[:pw])
     session = UserSession.create(:username => params[:u], :password => params[:pw], :remember_me => true); 
     session.save
      # @current_user = User.find_by_username(params[:u])
    end

    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
    return @current_user
  end
  
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
