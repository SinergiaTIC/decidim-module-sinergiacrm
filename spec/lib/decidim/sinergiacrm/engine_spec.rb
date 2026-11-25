# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sinergiacrm::Engine do
  let(:organization) { create(:organization) }

  it_behaves_like "clean engine"

  it "registers the login provider in Decidim" do
    expect(Decidim.omniauth_providers[:sinergia_crm]).to include(enabled: true, icon_path: "media/images/sinergiacrm-icon.png")
  end

  it "does not expose the client credentials in the provider settings" do
    expect(Decidim.omniauth_providers[:sinergia_crm].keys).to contain_exactly(:enabled, :icon_path)
  end

  it "enables the provider for organizations without custom settings" do
    expect(organization.enabled_omniauth_providers).to have_key(:sinergia_crm)
  end

  it "makes the provider available to the user model" do
    expect(Decidim::User.omniauth_providers).to include(:sinergia_crm)
  end

  it "adds the authorization route" do
    expect(Decidim::Core::Engine.routes.url_helpers.user_sinergia_crm_omniauth_authorize_path).to eq("/users/auth/sinergia_crm")
  end
end
