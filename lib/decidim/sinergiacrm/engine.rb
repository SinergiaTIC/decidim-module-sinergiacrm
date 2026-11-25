# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"
require "omniauth/strategies/sinergia_crm"

module Decidim
  module Sinergiacrm
    # This is the engine that runs on the public interface of sinergiacrm.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Sinergiacrm

      initializer "decidim_sinergiacrm.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_sinergiacrm.omniauth" do
        next unless Decidim::Sinergiacrm.omniauth[:enabled]

        Decidim.omniauth_providers[:sinergia_crm] = {
          enabled: true,
          icon_path: Decidim::Sinergiacrm.omniauth[:icon_path]
        }

        Rails.application.config.middleware.use OmniAuth::Builder do
          provider :sinergia_crm,
                   Decidim::Sinergiacrm.omniauth[:client_id],
                   Decidim::Sinergiacrm.omniauth[:client_secret],
                   client_options: {
                     site: Decidim::Sinergiacrm.omniauth[:site],
                     authorize_url: Decidim::Sinergiacrm.omniauth[:authorize_url],
                     token_url: Decidim::Sinergiacrm.omniauth[:token_url]
                   }
        end
      end
    end
  end
end
