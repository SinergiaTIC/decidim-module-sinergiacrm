# frozen_string_literal: true

class CreateDecidimSinergiacrmContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :decidim_sinergiacrm_contacts do |t|
      t.references :decidim_organization, null: false, foreign_key: true, index: false
      t.string :sinergiacrm_id, null: false
      t.string :name
      t.datetime :synced_at, null: false
      t.timestamps

      t.index [:decidim_organization_id, :sinergiacrm_id], unique: true, name: "index_sinergiacrm_contacts_on_organization_and_sinergiacrm_id"
      t.index [:decidim_organization_id, :name], name: "index_sinergiacrm_contacts_on_organization_and_name"
    end
  end
end
