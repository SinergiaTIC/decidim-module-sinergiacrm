# frozen_string_literal: true

require "decidim/sinergiacrm/admin"
require "decidim/sinergiacrm/engine"
require "decidim/sinergiacrm/admin_engine"
require "decidim/sinergiacrm/version"

module Decidim
  # This namespace holds the logic of the `decidim-sinergiacrm` module.
  module Sinergiacrm
    # Settings for the SinergiaCRM Portal OAuth2 login (authorization code flow).
    # The login provider is only registered when both the site and the client id are present.
    # Leave the client secret empty for public (non confidential) OAuth clients.
    mattr_accessor :omniauth, default: {
      enabled: ENV["SINERGIA_CRM_SITE"].present? && ENV["SINERGIA_CRM_CLIENT_ID"].present?,
      site: ENV["SINERGIA_CRM_SITE"].presence,
      client_id: ENV["SINERGIA_CRM_CLIENT_ID"].presence,
      client_secret: ENV["SINERGIA_CRM_CLIENT_SECRET"].presence,
      authorize_url: ENV["SINERGIA_CRM_AUTHORIZE_URL"].presence || "/index.php?entryPoint=sticPortalLogin",
      token_url: ENV["SINERGIA_CRM_TOKEN_URL"].presence || "/index.php?entryPoint=sticPortalOAuthToken",
      icon_path: ENV["SINERGIA_CRM_ICON"].presence || "media/images/sinergiacrm-icon.png"
    }

    # When enabled, the login shows a big SinergiaCRM button and the standard
    # email and password form is hidden behind an "Administration access" button.
    mattr_accessor :override_login, default: Decidim::Env.new("SINERGIA_CRM_OVERRIDE_LOGIN").present?

    # The login is only overridden in the organizations that have the SinergiaCRM provider enabled.
    def self.override_login?(organization)
      override_login && organization.enabled_omniauth_providers.has_key?(:sinergia_crm)
    end
  end
end
