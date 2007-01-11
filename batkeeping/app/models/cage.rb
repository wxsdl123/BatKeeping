class Cage < ActiveRecord::Base
    belongs_to  :user
	has_many :bats, :order => 'band'
	has_many :cage_in_histories, :order => "date desc"
	has_many :cage_out_histories, :order => "date desc"
    has_many :tasks
  
  def self.active
    find :all, :conditions => 'date_destroyed is null'
  end
  
  def update_weighing_tasks
    most_ancient_recent_weight = Time.now
    bats_have_weights = false
    for bat in self.bats
      if bat.weights.length > 0
        bats_have_weights = true
        if most_ancient_recent_weight > bat.weights.recent[0].date.to_time
          most_ancient_recent_weight = bat.weights.recent[0].date.to_time
        end
      end
    end
    if bats_have_weights
      for task in self.tasks
        task.last_done_date = most_ancient_recent_weight
        task.save
      end
    end
  end
  
end