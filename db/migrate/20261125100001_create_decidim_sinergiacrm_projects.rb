# frozen_string_literal: true

class CreateDecidimSinergiacrmProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :decidim_sinergiacrm_projects do |t|
      t.references :decidim_organization, null: false, foreign_key: true, index: false
      t.string :sinergiacrm_id, null: false
      t.string :name
      t.datetime :synced_at, null: false
      t.timestamps

      t.index [:decidim_organization_id, :sinergiacrm_id], unique: true, name: "index_sinergiacrm_projects_on_organization_and_sinergiacrm_id"
    end
  end
end
