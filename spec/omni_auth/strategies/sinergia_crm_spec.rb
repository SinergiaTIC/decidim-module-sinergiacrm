# frozen_string_literal: true

require "spec_helper"

describe OmniAuth::Strategies::SinergiaCrm do
  let(:strategy) { described_class.new(app, "client-id", "client-secret", client_options:) }
  let(:app) { ->(_env) { [200, {}, ["OK"]] } }
  let(:client_options) do
    {
      site: "https://crm.example.org",
      authorize_url: "/index.php?entryPoint=sticPortalLogin",
      token_url: "/index.php?entryPoint=sticPortalOAuthToken"
    }
  end
  let(:callback) { "https://decidim.example.org/users/auth/sinergia_crm/callback" }
  let(:portal_id) { "8d0b5c1e-4f0a-4d4e-9c55-1f6d2a7b3c10" }
  let(:portal_type) { "Contacts" }
  let(:user) { { "id" => portal_id, "email" => "john@example.org" } }
  let(:token_response) do
    {
      "access_token" => "access-token",
      "refresh_token" => "refresh-token",
      "token_type" => "Bearer",
      "expires_in" => 3600,
      "portal_id" => portal_id,
      "portal_type" => portal_type,
      "user" => user
    }
  end

  before do
    allow(strategy).to receive(:access_token).and_return(OAuth2::AccessToken.from_hash(strategy.client, token_response))
  end

  it "has the provider name" do
    expect(strategy.options.name).to eq("sinergia_crm")
  end

  describe "client" do
    it "sends the client credentials in the request body" do
      expect(strategy.client.options[:auth_scheme]).to eq(:request_body)
    end

    it "keeps the configured endpoints" do
      expect(strategy.client.site).to eq("https://crm.example.org")
      expect(strategy.client.token_url).to eq("https://crm.example.org/index.php?entryPoint=sticPortalOAuthToken")
    end

    it "builds the authorize url keeping the CRM entry point" do
      uri = URI.parse(strategy.client.auth_code.authorize_url(redirect_uri: callback))

      expect("#{uri.scheme}://#{uri.host}#{uri.path}").to eq("https://crm.example.org/index.php")
      expect(Rack::Utils.parse_query(uri.query)).to eq(
        "entryPoint" => "sticPortalLogin",
        "client_id" => "client-id",
        "redirect_uri" => callback,
        "response_type" => "code"
      )
    end
  end

  describe "callback_url" do
    before do
      allow(strategy).to receive_messages(
        full_host: "https://decidim.example.org",
        script_name: "",
        callback_path: "/users/auth/sinergia_crm/callback",
        query_string: "?code=abc&state=xyz"
      )
    end

    it "does not include the query string" do
      expect(strategy.callback_url).to eq(callback)
    end
  end

  describe "uid" do
    it "combines the portal type and the portal id" do
      expect(strategy.uid).to eq("Contacts:#{portal_id}")
    end

    context "when an organization logs in" do
      let(:portal_type) { "Accounts" }

      it "uses the account portal type" do
        expect(strategy.uid).to eq("Accounts:#{portal_id}")
      end
    end
  end

  describe "info" do
    it "returns the email" do
      expect(strategy.info).to eq(email: "john@example.org")
    end

    context "when the token response has no email" do
      let(:user) { { "id" => portal_id } }

      it "is empty" do
        expect(strategy.info).to be_empty
      end
    end
  end

  describe "extra" do
    it "exposes the portal identity without the tokens" do
      expect(strategy.extra[:raw_info]).to include("portal_id" => portal_id, "portal_type" => portal_type, "user" => user)
      expect(strategy.extra[:raw_info].keys).not_to include("access_token", "refresh_token")
    end
  end
end
