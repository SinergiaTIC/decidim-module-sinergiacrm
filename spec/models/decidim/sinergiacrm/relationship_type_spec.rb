# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe RelationshipType do
      subject { build(:sinergiacrm_relationship_type, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      context "without key" do
        before { subject.key = nil }

        it { is_expected.not_to be_valid }
      end

      context "without organization" do
        before { subject.organization = nil }

        it { is_expected.not_to be_valid }
      end

      context "when there is a relationship type with the same key in the same organization" do
        before { create(:sinergiacrm_relationship_type, organization:, key: subject.key) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:key]).to eq ["has already been taken"]
        end
      end

      context "when there is a relationship type with the same key in another organization" do
        before { create(:sinergiacrm_relationship_type, key: subject.key) }

        it { is_expected.to be_valid }
      end
    end
  end
end
