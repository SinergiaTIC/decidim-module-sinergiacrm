# frozen_string_literal: true

class CreateDecidimSinergiacrmRelationshipTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :decidim_sinergiacrm_relationship_types do |t|
      t.references :decidim_organization, null: false, foreign_key: true, index: false
      t.string :key, null: false
      t.string :name
      t.datetime :synced_at, null: false
      t.timestamps

      t.index [:decidim_organization_id, :key], unique: true, name: "index_sinergiacrm_relationship_types_on_organization_and_key"
    end
  end
end
