# frozen_string_literal: true

module Decidim
  module Sinergiacrm
    # A value of the SinergiaCRM dropdown list of contact relationship types.
    class RelationshipType < ApplicationRecord
      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: "decidim_organization_id"

      validates :key, presence: true, uniqueness: { scope: :decidim_organization_id }
    end
  end
end
