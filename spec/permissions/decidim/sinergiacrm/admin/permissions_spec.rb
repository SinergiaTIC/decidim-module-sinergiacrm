# frozen_string_literal: true

require "spec_helper"

module Decidim::Sinergiacrm::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create(:organization) }
    let(:context) { { current_organization: organization } }
    let(:action) { { scope: :admin, action: :read, subject: :sinergiacrm } }
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    context "when user is admin" do
      let(:user) { create(:user, :admin, organization:) }

      it { is_expected.to be_truthy }

      context "when scope is not admin" do
        let(:action) { { scope: :foo, action: :read, subject: :sinergiacrm } }

        it_behaves_like "permission is not set"
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user, organization:) }

      it_behaves_like "permission is not set"
    end
  end
end
