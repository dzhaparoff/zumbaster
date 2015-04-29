class CreateCrews < ActiveRecord::Migration
  def change
    create_table :crews do |t|
      t.string :job
      t.string :job_group
      t.references :show
      t.references :person
      t.timestamps
    end
  end
end
