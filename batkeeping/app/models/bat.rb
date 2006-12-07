class Bat < ActiveRecord::Base
	belongs_to :cage
	belongs_to :protocol
    has_many :cage_in_histories, :order => "date desc"
    has_many :cage_out_histories, :order => "date desc"
    
    #call this whenever you think the bat's cage could have changed
    #it updates both the cage out and cage in histories as required
    def log_cage_change(old_cage, new_cage)
        
        #We may have to close out the last cage_in_history
        #by creating a cage_out_history and attaching it to the cage_in_history
        unless old_cage == nil #this means we just created it
            cih = self.cage_in_histories #a list of histories sorted by latest date
            if cih
                cih = cih[0]
            else
                #Somebody screwed up and we gotta clean up the mess
                cih = CageInHistory.new
                cih.bat = self
                cih.cage = old_bat.cage
                cih.save
            end
            
            coh = CageOutHistory.new
            coh.bat = self
            coh.cage = old_cage
            coh.user = @current_user #session[:person]
            coh.date = Time.new 
            coh.cage_in_history = cih
            coh.save
            
        end

        #Make a new entry in the cage in histories
        cih = CageInHistory.new
        cih.bat = self
        cih.cage = new_cage
        cih.user = @current_user #session[:person]
        cih.date = Time.new 

        cih.save
    end
    
    #called just before creation
    def before_create
        @old_cage = nil
    end
    
    #before_save is called automatically just before a class is saved to the db
    # Tasks
    # 1. Save the original cage so we can use it to update cage change histories
    def before_save
        self.id ? @old_cage = Bat.find(self.id).cage : old_cage = nil
    end
        
    def after_save
        @new_cage = self.cage
        unless @old_cage == @new_cage
            log_cage_change(@old_cage, @new_cage)
        end
    end        
        
end