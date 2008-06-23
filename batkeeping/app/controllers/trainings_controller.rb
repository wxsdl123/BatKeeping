class TrainingsController < ApplicationController
  # GET /trainings
  # GET /trainings.xml
  def index
		if params[:selected_user]
			@selected_user = User.find(params[:selected_user])
			@trainings = Training.find(:all, :conditions => "user_id = #{User.find(params[:selected_user]).id}")
		else
			@trainings = Training.find(:all)
		end
  end

  # GET /trainings/1
  # GET /trainings/1.xml
  def show
		
		@training = Training.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @training }
    end
  end

  # GET /trainings/new
  # GET /trainings/new.xml
  def new
    if TrainingType.find(:all).length == 0
			flash[:notice] = 'You must create a training type first'
			redirect_to :controller => :Training_Types, :action => :new
		else
			if params[:selected_user]
				@selected_user = params[:selected_user].to_i
			end
			
			@training = Training.new

			respond_to do |format|
				format.html # new.html.erb
				format.xml  { render :xml => @training }
			end
		end
  end

  # GET /trainings/1/edit
  def edit
    @training = Training.find(params[:id])
  end

  # POST /trainings
  # POST /trainings.xml
  def create
		#error check to make sure user doesn't have duplicate entries of the same training
		if Training.find(:first, :conditions => "user_id = #{params[:training][:user_id]} and training_type_id = #{params[:training][:training_type_id]}")
			flash[:notice] = "User #{User.find(params[:training][:user_id]).name} is already trained with this training type."
			redirect_to :back
		else
			@training = Training.new(params[:training])
			if @training.save
				flash[:notice] = 'Training was successfully created.'
				redirect_to :controller => :trainings, :action => :index, :selected_user => @training.user.id
			else
				format.html { render :action => "new" }
				format.xml  { render :xml => @training.errors, :status => :unprocessable_entity }
			end
		end
  end

  # PUT /trainings/1
  # PUT /trainings/1.xml
  def update
    @training = Training.find(params[:id])

    respond_to do |format|
      if @training.update_attributes(params[:training])
        flash[:notice] = 'Training was successfully updated.'
        format.html { redirect_to(@training) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trainings/1
  # DELETE /trainings/1.xml
  def destroy
    @training = Training.find(params[:id])
    @training.destroy

    respond_to do |format|
      format.html { redirect_to(trainings_url) }
      format.xml  { head :ok }
    end
  end
end
