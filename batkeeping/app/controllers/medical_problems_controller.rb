class MedicalProblemsController < ApplicationController
  def index
    redirect_to :action => 'list_current'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @medical_problems = MedicalProblem.find(:all)
    bat_ids = Array.new
    for medical_problem in @medical_problems
      bat_ids << medical_problem.bat.id
    end
    @bats = Bat.find(bat_ids.uniq, :order => 'band')
    render :action => 'list'
  end

  def list_current
    @list_all = false
    list
  end

  def list_all
    @list_all = true
    list
  end
  
  def show
    @medical_problem = MedicalProblem.find(params[:id])
  end

  def new
    @medical_problem = MedicalProblem.new
    @bats = Bat.find(:all, :conditions => "leave_date is null", :order => "band")
    @deactivating = false
  end

  def create
    @bat = Bat.find(params[:bat][:id])
    @medical_problem = MedicalProblem.new(params[:medical_problem])
    @medical_problem.date_closed = nil
    @medical_problem.bat = @bat
    @medical_problem.user = session[:person]
    if @medical_problem.save
      flash[:notice] = 'MedicalProblem was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bats = Bat.find(:all, :conditions => "leave_date is null", :order => "band")
    @medical_problem = MedicalProblem.find(params[:id])
    @deactivating = false
  end

  def update
    @medical_problem = MedicalProblem.find(params[:id])
    @deactivating = params[:deactivating]
    if @medical_problem.update_attributes(params[:medical_problem])
      if @deactivating
          for proposed_treatment in @medical_problem.proposed_treatments
            proposed_treatment.date_closed = @medical_problem.date_closed
            proposed_treatment.save
          end
      end
      flash[:notice] = 'Medical Problem was successfully updated.'
    else
      render :action => 'edit'
    end
	  if params[:redirectme] == 'list_current'
		redirect_to :action => 'list_current'
	  else
		redirect_to :action => 'show', :id => @medical_problem
	  end
  end

  def destroy
    MedicalProblem.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def deactivate
	@medical_problem = MedicalProblem.find(params[:id])
  @bats = Bat.find(:all, :conditions => "leave_date is null", :order => "band")
  @deactivating = true
  end
  
  def reactivate
    @medical_problem = MedicalProblem.find(params[:id])
    @medical_problem.date_closed = nil
    @medical_problem.save
    redirect_to :action => 'list'
  end
end
