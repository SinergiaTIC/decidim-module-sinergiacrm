# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe Project do
      subject { build(:sinergiacrm_project, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      context "without sinergiacrm_id" do
        before { subject.sinergiacrm_id = nil }

        it { is_expected.not_to be_valid }
      end

      context "without organization" do
        before { subject.organization = nil }

        it { is_expected.not_to be_valid }
      end

      context "when there is a project with the same sinergiacrm_id in the same organization" do
        before { create(:sinergiacrm_project, organization:, sinergiacrm_id: subject.sinergiacrm_id) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:sinergiacrm_id]).to eq ["has already been taken"]
        end
      end

      context "when there is a project with the same sinergiacrm_id in another organization" do
        before { create(:sinergiacrm_project, sinergiacrm_id: subject.sinergiacrm_id) }

        it { is_expected.to be_valid }
      end

      it "keeps the relationships without a project when destroyed" do
        relationship = create(:sinergiacrm_contact_relationship, project: subject, organization:)

        expect { subject.destroy }.not_to change(ContactRelationship, :count)
        expect(relationship.reload.project).to be_nil
      end
    end
  end
end
