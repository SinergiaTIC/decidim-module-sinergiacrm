# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe Contact do
      subject { build(:sinergiacrm_contact, organization:) }

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

      context "when there is a contact with the same sinergiacrm_id in the same organization" do
        before { create(:sinergiacrm_contact, organization:, sinergiacrm_id: subject.sinergiacrm_id) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:sinergiacrm_id]).to eq ["has already been taken"]
        end
      end

      context "when there is a contact with the same sinergiacrm_id in another organization" do
        before { create(:sinergiacrm_contact, sinergiacrm_id: subject.sinergiacrm_id) }

        it { is_expected.to be_valid }
      end

      it "destroys its contact relationships" do
        create(:sinergiacrm_contact_relationship, contact: subject, organization:)

        expect { subject.destroy }.to change(ContactRelationship, :count).by(-1)
      end

      context "with active and inactive relationships" do
        let!(:active_contact) { create(:sinergiacrm_contact, organization:) }
        let!(:inactive_contact) { create(:sinergiacrm_contact, organization:) }
        let!(:contact_without_relationships) { create(:sinergiacrm_contact, organization:) }

        before do
          create(:sinergiacrm_contact_relationship, contact: active_contact, organization:)
          create(:sinergiacrm_contact_relationship, :inactive, contact: active_contact, organization:)
          create(:sinergiacrm_contact_relationship, :inactive, contact: inactive_contact, organization:)
        end

        describe "#active?" do
          it "is true with at least one active relationship" do
            expect(active_contact).to be_active
            expect(inactive_contact).not_to be_active
            expect(contact_without_relationships).not_to be_active
          end
        end

        describe ".active" do
          it "returns the contacts with an active relationship" do
            expect(described_class.active).to contain_exactly(active_contact)
          end
        end

        describe ".inactive" do
          it "returns the contacts without an active relationship" do
            expect(described_class.inactive).to contain_exactly(inactive_contact, contact_without_relationships)
          end
        end

        describe ".with_any_status" do
          it "returns the contacts of the given statuses" do
            expect(described_class.with_any_status("active")).to contain_exactly(active_contact)
            expect(described_class.with_any_status("inactive")).to contain_exactly(inactive_contact, contact_without_relationships)
            expect(described_class.with_any_status("active", "inactive").count).to eq(3)
          end
        end
      end

      describe ".with_relationship_type" do
        let!(:member) { create(:sinergiacrm_contact, organization:) }
        let!(:volunteer) { create(:sinergiacrm_contact, organization:) }

        before do
          create_list(:sinergiacrm_contact_relationship, 2, contact: member, organization:, relationship_type: "member")
          create(:sinergiacrm_contact_relationship, contact: volunteer, organization:, relationship_type: "volunteer")
        end

        it "returns each contact with a relationship of the type once" do
          expect(described_class.with_relationship_type("member")).to contain_exactly(member)
        end

        it "accepts several keys through ransack" do
          expect(described_class.ransack(with_relationship_type: %w(member volunteer)).result).to contain_exactly(member, volunteer)
        end

        # Decidim disables Ransack's boolean casting of scope arguments (sanitize_custom_scope_booleans)
        context "when the key looks like a boolean" do
          let!(:numeric) { create(:sinergiacrm_contact, organization:) }
          let!(:negative) { create(:sinergiacrm_contact, organization:) }

          before do
            create(:sinergiacrm_contact_relationship, contact: numeric, organization:, relationship_type: "1")
            create(:sinergiacrm_contact_relationship, contact: negative, organization:, relationship_type: "false")
          end

          it "filters by the key through ransack" do
            expect(described_class.ransack(with_relationship_type: "1").result).to contain_exactly(numeric)
            expect(described_class.ransack(with_relationship_type: "false").result).to contain_exactly(negative)
          end
        end
      end

      describe ".ransack" do
        let!(:contact) { create(:sinergiacrm_contact, organization:, name: "Jane Roe", sinergiacrm_id: "crm-123") }

        before { create(:sinergiacrm_contact, organization:, name: "John Doe") }

        it "searches by name or SinergiaCRM ID" do
          expect(described_class.ransack(name_or_sinergiacrm_id_cont: "jane").result).to contain_exactly(contact)
          expect(described_class.ransack(name_or_sinergiacrm_id_cont: "crm-12").result).to contain_exactly(contact)
        end
      end
    end
  end
end
