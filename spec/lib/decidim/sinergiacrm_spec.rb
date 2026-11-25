# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sinergiacrm do
  describe ".omniauth" do
    it "is enabled when the site and the client id are present" do
      expect(described_class.omniauth).to include(
        enabled: true,
        site: "https://crm.example.org",
        client_id: "sinergiacrm-test-client-id",
        client_secret: "sinergiacrm-test-client-secret"
      )
    end

    it "defaults to the SinergiaCRM portal endpoints" do
      expect(described_class.omniauth).to include(
        authorize_url: "/index.php?entryPoint=sticPortalLogin",
        token_url: "/index.php?entryPoint=sticPortalOAuthToken"
      )
    end
  end

  describe ".override_login?" do
    subject { described_class.override_login?(organization) }

    let(:organization) { create(:organization) }
    let(:override_login) { true }
    let(:providers) { { sinergia_crm: { enabled: true } } }

    before do
      allow(described_class).to receive(:override_login).and_return(override_login)
      allow(organization).to receive(:enabled_omniauth_providers).and_return(providers)
    end

    it { is_expected.to be(true) }

    context "when the setting is disabled" do
      let(:override_login) { false }

      it { is_expected.to be(false) }
    end

    context "when the organization has the provider disabled" do
      let(:providers) { { developer: { enabled: true } } }

      it { is_expected.to be(false) }
    end
  end
end
