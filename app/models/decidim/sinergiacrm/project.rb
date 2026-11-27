# frozen_string_literal: true

module Decidim
  module Sinergiacrm
    # A project synchronized from SinergiaCRM.
    class Project < ApplicationRecord
      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: "decidim_organization_id"

      has_many :contact_relationships, class_name: "Decidim::Sinergiacrm::ContactRelationship", dependent: :nullify

      validates :sinergiacrm_id, presence: true, uniqueness: { scope: :decidim_organization_id }
    end
  end
end
