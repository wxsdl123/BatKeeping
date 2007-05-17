class RoomsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @rooms = Room.find(:all)
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(params[:room])
    if @room.save
      flash[:notice] = 'Rooms was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @room = Room.find(params[:id])
  end

  def update
    @room = Room.find(params[:id])
    if @room.update_attributes(params[:room])
      flash[:notice] = 'Room was successfully updated.'
      redirect_to :action => 'show', :id => @room
    else
      render :action => 'edit'
    end
  end

  def destroy
    @room = Room.find(params[:id])
		
		if @room.cages.active.length > 0
			flash[:notice] = 'Deactivation failed.  Room still has cages.'
			redirect_to :action => 'show', :id => @room
		else
			@room.destroy
			redirect_to :action => 'list'
		end
  end
end
