# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe Project do
      subject { create(:sinergiacrm_project, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      it "is invalid without sinergiacrm_id" do
        subject.sinergiacrm_id = nil

        expect(subject).not_to be_valid
      end

      it "does not repeat sinergiacrm_id inside an organization" do
        duplicate = build(:sinergiacrm_project, organization:, sinergiacrm_id: subject.sinergiacrm_id)

        expect(duplicate).not_to be_valid
      end

      it "allows the same sinergiacrm_id in another organization" do
        other = build(:sinergiacrm_project, organization: create(:organization), sinergiacrm_id: subject.sinergiacrm_id)

        expect(other).to be_valid
      end

      it "keeps the relationships without a project when destroyed" do
        relationship = create(:sinergiacrm_contact_relationship, project: subject, organization:)

        expect { subject.destroy }.not_to change(Decidim::Sinergiacrm::ContactRelationship, :count)
        expect(relationship.reload.project).to be_nil
      end
    end
  end
end
