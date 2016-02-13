class CreateAddPayloadComposite < ActiveRecord::Migration
  def change
    change_table :payloads do |t|
      t.string :composite_key
    end
  end
end
