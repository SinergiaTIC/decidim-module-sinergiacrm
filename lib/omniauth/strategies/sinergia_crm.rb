# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    # OAuth2 strategy for the SinergiaCRM Portal (authorization code flow).
    class SinergiaCrm < OmniAuth::Strategies::OAuth2
      option :name, "sinergia_crm"
      # SinergiaCRM expects the client credentials in the POST body of the token request.
      option :client_options, { auth_scheme: :request_body }
      option :authorize_options, [:scope]

      # OmniAuth normally appends the current request's query string to the
      # callback URL. SinergiaCRM requires the registered redirect URI exactly,
      # without query parameters, for both authorization and token exchange.
      def callback_url
        super.split("?", 2).first
      end

      # Contact and account UUIDs can overlap, so include the portal type.
      uid { "#{raw_info["portal_type"]}:#{raw_info["portal_id"]}" }

      info do
        {
          email: raw_info.dig("user", "email")
        }.compact
      end

      extra do
        { raw_info: }
      end

      # The token response already carries the portal identity, there is no user info endpoint.
      def raw_info
        @raw_info ||= access_token.params
      end
    end
  end
end
