# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe RelationshipType do
      subject { create(:sinergiacrm_relationship_type, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      it "is invalid without key" do
        subject.key = nil

        expect(subject).not_to be_valid
      end

      it "does not repeat key inside an organization" do
        duplicate = build(:sinergiacrm_relationship_type, organization:, key: subject.key)

        expect(duplicate).not_to be_valid
      end

      it "allows the same key in another organization" do
        other = build(:sinergiacrm_relationship_type, organization: create(:organization), key: subject.key)

        expect(other).to be_valid
      end
    end
  end
end
