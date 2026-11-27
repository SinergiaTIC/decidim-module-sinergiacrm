# frozen_string_literal: true

class CreateDecidimSinergiacrmContactRelationships < ActiveRecord::Migration[8.1]
  def change
    create_table :decidim_sinergiacrm_contact_relationships do |t|
      t.references :decidim_organization, null: false, foreign_key: true, index: false
      t.references :contact, null: false, foreign_key: { to_table: :decidim_sinergiacrm_contacts }, index: false
      t.references :project, foreign_key: { to_table: :decidim_sinergiacrm_projects }, index: { name: "index_sinergiacrm_contact_relationships_on_project_id" }
      t.string :sinergiacrm_id, null: false
      t.string :relationship_type
      t.boolean :active, null: false, default: false
      t.date :start_date
      t.date :end_date
      t.datetime :synced_at, null: false
      t.timestamps

      t.index [:contact_id, :active], name: "index_sinergiacrm_contact_relationships_on_contact_and_active"
      t.index [:decidim_organization_id, :sinergiacrm_id], unique: true, name: "index_sinergiacrm_contact_relationships_on_org_and_crm_id"
      t.index [:decidim_organization_id, :relationship_type], name: "index_sinergiacrm_contact_relationships_on_org_and_type"
    end
  end
end
