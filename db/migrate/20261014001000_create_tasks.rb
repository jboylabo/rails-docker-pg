class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.datetime :due_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :tasks, [ :user_id, :status ]
    add_index :tasks, :due_at
  end
end