class Cage < ActiveRecord::Base
    belongs_to  :user
    has_many :bats, :order => 'band'
    has_many :cage_in_histories, :order => "date desc"
    has_many :cage_out_histories, :order => "date desc"
    has_many :tasks, :order => "repeat_code"
    belongs_to :room
  
  def self.active
    find :all, :conditions => 'date_destroyed is null', :order => 'name'
  end
  
  def self.has_bats
    @cages = find :all, :order => "name"
    for cage in @cages
      @cages.delete_if{|cage| cage.bats.length == 0}
    end
		@cages = @cages.sort_by{|cage| [cage.name]}
    return @cages
  end
  
  def self.has_feeding_tasks
		@cages = find :all, :order => "name"
		for cage in @cages
			@cages.delete_if{|cage| cage.tasks.feeding_tasks.length == 0}
		end
		@cages = @cages.sort_by{|cage| [cage.name]}
		return @cages
  end
  
  def average_bat_weight
    if self.bats.length > 0
      combined_weights = 0.0
      num_bats_with_weights = 0
      for bat in self.bats
        if bat.weights.length > 0 
          combined_weights = combined_weights + bat.weights.recent.weight
          num_bats_with_weights = num_bats_with_weights + 1
        end
      end
      if num_bats_with_weights > 0 
        average = combined_weights/num_bats_with_weights
        return (("%.0" + 1.to_s + "f") %average).to_f
      else
        return 0
      end
    else 
      return 0
    end
  end
  
  def food_today
    food = 0
    self.tasks.feeding_tasks_today.each {|task| task.food ? food = food + task.food : food }
    return food
  end
  
  def food_this_week
    food = 0
    self.tasks.feeding_tasks.each {|task| task.food ? food = food + task.food : food }
    return food
  end
    
  def fed_today?
    today = Date.today.wday + 1 #to bring in line with repeat_codes
    for task in self.tasks.feeding_tasks
      if (task.repeat_code == today && task.done_by_schedule == true)
        return true
      end
    end
    return false
  end
	
	def fed_every_day?
    if self.tasks.feeding_tasks.length < 7
      return false
    end
    
    day = 0
    7.times do
      task_exists = false
      day = day + 1
      self.tasks.feeding_tasks.each{|task| (task.repeat_code == day) ? task_exists = true : '' }
      if task_exists == false 
        return false
      end
    end
    return true
  end
  
  def oldest_recent_weight #this function returns the oldest of the dates of all the bats recent weights
		#initializing
    oldest_recent_weight = Time.now
    
    for bat in self.bats
      bats_have_weights = false
			if bat.weights.length > 0 #this bat has weights
        all_bats_have_weights = true
        if oldest_recent_weight > bat.weights.recent.date.to_time
          oldest_recent_weight = bat.weights.recent.date.to_time
        end
      end
    end
		
		if all_bats_have_weights
			return oldest_recent_weight
		else
			return nil
		end
  end
end