# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe ContactRelationship do
      subject { create(:sinergiacrm_contact_relationship, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      it "is valid without project" do
        subject.project = nil

        expect(subject).to be_valid
      end

      it "is invalid without contact" do
        subject.contact = nil

        expect(subject).not_to be_valid
      end

      it "is invalid without sinergiacrm_id" do
        subject.sinergiacrm_id = nil

        expect(subject).not_to be_valid
      end

      it "does not repeat sinergiacrm_id inside an organization" do
        duplicate = build(:sinergiacrm_contact_relationship, organization:, sinergiacrm_id: subject.sinergiacrm_id)

        expect(duplicate).not_to be_valid
      end

      it "allows the same sinergiacrm_id in another organization" do
        other = build(:sinergiacrm_contact_relationship, organization: create(:organization), sinergiacrm_id: subject.sinergiacrm_id)

        expect(other).to be_valid
      end

      it "is invalid with a contact of another organization" do
        subject.contact = create(:sinergiacrm_contact, organization: create(:organization))

        expect(subject).not_to be_valid
      end

      it "is invalid with a project of another organization" do
        subject.project = create(:sinergiacrm_project, organization: create(:organization))

        expect(subject).not_to be_valid
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
