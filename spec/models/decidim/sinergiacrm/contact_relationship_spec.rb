# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe ContactRelationship do
      subject { build(:sinergiacrm_contact_relationship, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      context "without project" do
        before { subject.project = nil }

        it { is_expected.to be_valid }
      end

      context "without contact" do
        before { subject.contact = nil }

        it { is_expected.not_to be_valid }
      end

      context "without sinergiacrm_id" do
        before { subject.sinergiacrm_id = nil }

        it { is_expected.not_to be_valid }
      end

      context "without organization" do
        before { subject.organization = nil }

        it { is_expected.not_to be_valid }
      end

      context "when there is a relationship with the same sinergiacrm_id in the same organization" do
        before { create(:sinergiacrm_contact_relationship, organization:, sinergiacrm_id: subject.sinergiacrm_id) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:sinergiacrm_id]).to eq ["has already been taken"]
        end
      end

      context "when there is a relationship with the same sinergiacrm_id in another organization" do
        before do
          other_organization = create(:organization)
          create(:sinergiacrm_contact_relationship, organization: other_organization, sinergiacrm_id: subject.sinergiacrm_id)
        end

        it { is_expected.to be_valid }
      end

      context "with a contact of another organization" do
        before { subject.contact = create(:sinergiacrm_contact) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:contact]).to eq ["is invalid"]
        end
      end

      context "with a project of another organization" do
        before { subject.project = create(:sinergiacrm_project) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:project]).to eq ["is invalid"]
        end
      end

      describe ".active" do
        let!(:active) { create(:sinergiacrm_contact_relationship, organization:) }

        before { create(:sinergiacrm_contact_relationship, :inactive, organization:) }

        it "returns only active relationships" do
          expect(described_class.active).to contain_exactly(active)
        end
      end
    end
  end
end
