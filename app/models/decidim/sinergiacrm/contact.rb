# frozen_string_literal: true

module Decidim
  module Sinergiacrm
    # A contact synchronized from SinergiaCRM. Contacts are created from their relationships.
    class Contact < ApplicationRecord
      include Decidim::FilterableResource

      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: "decidim_organization_id"

      has_many :contact_relationships, class_name: "Decidim::Sinergiacrm::ContactRelationship", dependent: :destroy

      validates :sinergiacrm_id, presence: true, uniqueness: { scope: :decidim_organization_id }

      scope :active, -> { where(id: ContactRelationship.active.select(:contact_id)) }
      scope :inactive, -> { where.not(ContactRelationship.active.where(ContactRelationship.arel_table[:contact_id].eq(arel_table[:id])).arel.exists) }
      scope_search_multi :with_any_status, [:active, :inactive]
      scope :with_relationship_type, ->(*keys) { where(id: ContactRelationship.where(relationship_type: keys.flatten).select(:contact_id)) }

      def self.ransackable_attributes(_auth_object = nil)
        %w(name sinergiacrm_id)
      end

      def self.ransackable_associations(_auth_object = nil)
        []
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_status, :with_relationship_type]
      end

      # A contact is active when it has at least one active relationship.
      # Preload the relationships when listing contacts to avoid one query per contact.
      def active?
        contact_relationships.any?(&:active?)
      end
    end
  end
end
