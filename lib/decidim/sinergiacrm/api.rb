# frozen_string_literal: true

require "faraday"

module Decidim
  module Sinergiacrm
    # Access to the SinergiaCRM API V8, configured with `Decidim::Sinergiacrm.api`.
    module Api
      # Raised on any failure talking to the API: HTTP errors, network errors,
      # unparsable responses or missing configuration.
      class Error < StandardError; end
    end
  end
end

require "decidim/sinergiacrm/api/client"
