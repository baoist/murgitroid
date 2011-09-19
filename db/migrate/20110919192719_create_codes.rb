class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.int :master
      t.string :key_a
      t.string :key_b
      t.text :message
      t.text :message_coded
      t.string :ip

      t.timestamps
    end
  end
end
