class AddTitleToPapps < ActiveRecord::Migration
  def change
    add_column :papps, :title, :string

  end
end
