class CreateCageHistories < ActiveRecord::Migration
  def self.up
    create_table :cage_histories do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :cage_histories
  end
end