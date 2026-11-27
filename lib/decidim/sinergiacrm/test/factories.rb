# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :sinergiacrm_contact, class: "Decidim::Sinergiacrm::Contact" do
    organization
    sinergiacrm_id { SecureRandom.uuid }
    name { Faker::Name.name }
    synced_at { Time.current }
  end

  factory :sinergiacrm_project, class: "Decidim::Sinergiacrm::Project" do
    organization
    sinergiacrm_id { SecureRandom.uuid }
    name { Faker::Lorem.words(number: 3).join(" ") }
    synced_at { Time.current }
  end

  factory :sinergiacrm_relationship_type, class: "Decidim::Sinergiacrm::RelationshipType" do
    organization
    sequence(:key) { |n| "type_#{n}" }
    name { Faker::Lorem.word }
    synced_at { Time.current }
  end

  factory :sinergiacrm_contact_relationship, class: "Decidim::Sinergiacrm::ContactRelationship" do
    organization
    contact { association(:sinergiacrm_contact, organization:) }
    project { association(:sinergiacrm_project, organization:) }
    sinergiacrm_id { SecureRandom.uuid }
    relationship_type { "member" }
    active { true }
    start_date { 1.year.ago.to_date }
    end_date { nil }
    synced_at { Time.current }

    trait :inactive do
      active { false }
      end_date { 1.month.ago.to_date }
    end
  end
end
