class UpdatePayloadTableTypes < ActiveRecord::Migration
  def change
    change_table :payloads do |t|
      t.remove :url_id
      t.remove :referred_id
      t.remove :event_name_id
      t.remove :ip_id

      t.integer :url_id
      t.integer :referred_id
      t.integer :event_name_id
      t.integer :ip_id
    end
  end
end
