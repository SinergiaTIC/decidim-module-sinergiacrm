# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)
ENV["NODE_ENV"] ||= "test"

# Enable the SinergiaCRM login provider for tests, ignoring any local configuration
ENV.delete_if { |name, _value| name.start_with?("SINERGIA_CRM_") }
ENV["SINERGIA_CRM_SITE"] = "https://crm.example.org"
ENV["SINERGIA_CRM_CLIENT_ID"] = "sinergiacrm-test-client-id"
ENV["SINERGIA_CRM_CLIENT_SECRET"] = "sinergiacrm-test-client-secret"

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"
