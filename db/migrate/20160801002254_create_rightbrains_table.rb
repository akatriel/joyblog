class CreateRightbrainsTable < ActiveRecord::Migration
  def change
  	create_table :rightbrains do |t|
  		t.string :title
  		t.text :body
  		t.timestamps
  	end
  end
end
