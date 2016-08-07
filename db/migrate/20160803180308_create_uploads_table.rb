class CreateUploadsTable < ActiveRecord::Migration
  def change
  	create_table :uploads do |t|
  		t.string :url
  		t.integer :leftbrainid
  		t.integer :rightbrainid
  		t.timestamps
  	end
  end
end
