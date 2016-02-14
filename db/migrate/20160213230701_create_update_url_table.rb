class CreateUpdateUrlTable < ActiveRecord::Migration
  def change
    change_table :urls do |t|
      t.remove :path
      t.remove :verb
    end
  end
end
