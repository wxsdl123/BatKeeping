class FlightsController < ApplicationController
  def index
    redirect_to :action => 'list'
  end
  
  def list
    user = User.find(session[:person])
	@bats = user.users_bats
	@list = "mine"
  end

  def list_current
	@bats = Bat.active
	@list = "current"
	render :action => :list
  end
  
  def list_all
    @bats = Bat.find(:all, :order => 'band')
	@list = "all"
    render :action => 'list'
  end

  def list_deactivated
	@bats = Bat.not_active
	@list = "deactivated"
	render :action => 'list'
  end
  
  def show
	@bat = Bat.find(params[:id])
	@flight_dates, @flights  = @bat.flight_dates(Date.today.year,Date.today.mon)
  end
  
  def remote_show
	@this_month = Date.strptime(params[:this_month])
	if @month.to_s == Date.today.mon.to_s
		@highlight_today = true
	else
		@highlight_today = false
	end
	@bat = Bat.find(params[:id])
	@flight_dates, @flights  = @bat.flight_dates(@this_month.year,@this_month.mon)
	render :partial => 'remote_show', :locals=>{:bat=>@bat, :highlight_today=>@highlight_today, :this_month => @this_month, :flight_dates => @flight_dates, :flights =>@flights}
  end
  
  def new
	@flight = Flight.new
  end
  
  def create
	@flight = Flight.new(params[:flight])
	
	if @flight.date > Date.today
		flash[:notice] = 'Flight date cannot be in the future.'
		render :action => :new
	else
		@flight.user = User.find(session[:person])
		if @flight.save
			flash[:notice] = 'Flight was successfully created.'
			redirect_to :action => :show, :id => @flight.bat
		else
			render :action => :new
		end
	end
  end
  
  def remote_bat_list
	bats = Bat.find(params[:bats], :order => 'band')
	render :partial => 'bat_select', :locals => {:bats => bats}
  end
  
  def destroy
	Flight.find(params[:id]).destroy
    redirect_to :action => 'show', :id => params[:bat]
  end
end