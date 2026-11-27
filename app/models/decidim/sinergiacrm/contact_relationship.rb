# frozen_string_literal: true

module Decidim
  module Sinergiacrm
    # A relationship of a contact synchronized from SinergiaCRM. It has a type
    # (member, volunteer...), and may be linked to a project.
    class ContactRelationship < ApplicationRecord
      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: "decidim_organization_id"
      belongs_to :contact, class_name: "Decidim::Sinergiacrm::Contact"
      belongs_to :project, class_name: "Decidim::Sinergiacrm::Project", optional: true

      validates :sinergiacrm_id, presence: true, uniqueness: { scope: :decidim_organization_id }
      validate :contact_and_project_in_the_same_organization

      scope :active, -> { where(active: true) }

      private

      def contact_and_project_in_the_same_organization
        errors.add(:contact, :invalid) if contact && contact.decidim_organization_id != decidim_organization_id
        errors.add(:project, :invalid) if project && project.decidim_organization_id != decidim_organization_id
      end
    end
  end
end
