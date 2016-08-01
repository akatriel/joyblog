class CreateTable < ActiveRecord::Migration
  def change
  	create_table :leftbrains do |t|
  		t.string :title
  		t.text :body
  		t.timestamps
  	end
  end
end
