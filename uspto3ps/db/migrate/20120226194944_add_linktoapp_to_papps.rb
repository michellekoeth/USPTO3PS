class AddLinktoappToPapps < ActiveRecord::Migration
  def change
    add_column :papps, :linktoapp, :string

  end
end
