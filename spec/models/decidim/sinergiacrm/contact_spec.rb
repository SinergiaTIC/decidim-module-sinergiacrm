# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sinergiacrm
    describe Contact do
      subject { create(:sinergiacrm_contact, organization:) }

      let(:organization) { create(:organization) }

      it { is_expected.to be_valid }

      it "is invalid without sinergiacrm_id" do
        subject.sinergiacrm_id = nil

        expect(subject).not_to be_valid
      end

      it "does not repeat sinergiacrm_id inside an organization" do
        duplicate = build(:sinergiacrm_contact, organization:, sinergiacrm_id: subject.sinergiacrm_id)

        expect(duplicate).not_to be_valid
      end

      it "allows the same sinergiacrm_id in another organization" do
        other = build(:sinergiacrm_contact, organization: create(:organization), sinergiacrm_id: subject.sinergiacrm_id)

        expect(other).to be_valid
      end

      it "destroys its contact relationships" do
        create(:sinergiacrm_contact_relationship, contact: subject, organization:)

        expect { subject.destroy }.to change(Decidim::Sinergiacrm::ContactRelationship, :count).by(-1)
      end

      describe "status" do
        let!(:active_contact) { create(:sinergiacrm_contact, organization:) }
        let!(:inactive_contact) { create(:sinergiacrm_contact, organization:) }
        let!(:contact_without_relationships) { create(:sinergiacrm_contact, organization:) }

        before do
          create(:sinergiacrm_contact_relationship, contact: active_contact, organization:)
          create(:sinergiacrm_contact_relationship, :inactive, contact: active_contact, organization:)
          create(:sinergiacrm_contact_relationship, :inactive, contact: inactive_contact, organization:)
        end

        it "is active with at least one active relationship" do
          expect(active_contact).to be_active
          expect(inactive_contact).not_to be_active
          expect(contact_without_relationships).not_to be_active
        end

        it "filters active contacts" do
          expect(described_class.active).to contain_exactly(active_contact)
        end

        it "filters inactive contacts" do
          expect(described_class.inactive).to contain_exactly(inactive_contact, contact_without_relationships)
        end

        it "filters by any status" do
          expect(described_class.with_any_status("active")).to contain_exactly(active_contact)
          expect(described_class.with_any_status("inactive")).to contain_exactly(inactive_contact, contact_without_relationships)
          expect(described_class.with_any_status("active", "inactive").count).to eq(3)
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
