class CreatePapps < ActiveRecord::Migration
  def change
    create_table :papps do |t|
      t.string :appno
      t.string :firstinventorname
      t.string :assignee
      t.date :filingdate
      t.string :apptype
      t.string :examinername
      t.integer :artunit
      t.integer :confnumber
      t.string :classsub
      t.boolean :published
      t.date :pubdate
      t.date :firstoadate
      t.date :noadate
      t.date :issuedate
      t.string :currstatus
      t.date :currstatusdate
      t.string :pubno
      t.boolean :pubrequest

      t.timestamps
    end
  end
end
