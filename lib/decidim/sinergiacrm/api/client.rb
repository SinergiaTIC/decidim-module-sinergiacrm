# frozen_string_literal: true

module Decidim
  module Sinergiacrm
    module Api
      # Reads records and field definitions from the SinergiaCRM API V8 (JSON:API)
      # using an OAuth2 client credentials token cached in `Rails.cache`.
      class Client
        # Returns one page of records of a module:
        #   { records: [{ "id" => ..., "type" => ..., "attributes" => { ... } }], total_pages: 2 }
        def records(module_name, page:)
          # Without page[size] the server ignores the page number and returns 20 records and no total pages
          body = get("V8/module/#{module_name}", page: { number: page, size: settings[:page_size] })

          data = body["data"]
          meta = body["meta"]
          raise Error, "SinergiaCRM API returned an unexpected response" unless (data.nil? || data.is_a?(Array)) && (meta.nil? || meta.is_a?(Hash))

          records = Array(data)
          total_pages = meta&.dig("total-pages")
          # Without the page count a page with records cannot be told apart from the last one
          raise Error, "SinergiaCRM API returned records without the total pages" if records.any? && total_pages.blank?

          { records:, total_pages: total_pages.to_i }
        end

        # Returns the field definitions of a module, keyed by field name.
        def fields(module_name)
          data = get("V8/meta/fields/#{module_name}")["data"]
          attributes = data["attributes"] if data.is_a?(Hash)

          attributes.is_a?(Hash) ? attributes.select { |_name, field| field.is_a?(Hash) } : {}
        end

        private

        def get(path, params = {})
          response = with_connection { |connection| connection.get(path, params, "Authorization" => "Bearer #{access_token}") }
          Rails.cache.delete(token_cache_key) if response.status == 401

          parse(response)
        end

        def access_token
          Rails.cache.read(token_cache_key) || request_access_token
        end

        def request_access_token
          payload = { grant_type: "client_credentials", client_id: settings[:client_id], client_secret: settings[:client_secret] }
          body = parse(with_connection { |connection| connection.post("access_token", payload.to_json) })
          token = body["access_token"]
          raise Error, "SinergiaCRM API token response has no access_token" if token.blank?

          # Keep a margin so a token is never used right at its expiry
          ttl = body["expires_in"].to_i - 60
          Rails.cache.write(token_cache_key, token, expires_in: ttl) if ttl.positive?
          token
        end

        def token_cache_key
          "decidim-sinergiacrm/api-token/#{Digest::SHA256.hexdigest("#{settings[:site]}|#{settings[:client_id]}")}"
        end

        def with_connection
          yield connection
        rescue Faraday::Error => e
          raise Error, "SinergiaCRM API request failed: #{e.class}: #{e.message}"
        end

        def parse(response)
          body = begin
            JSON.parse(response.body.to_s)
          rescue JSON::ParserError
            nil
          end
          raise Error, error_message(response, body) unless response.success?
          raise Error, "SinergiaCRM API returned an unparsable response (HTTP #{response.status})" unless body.is_a?(Hash)

          body
        end

        # 400 bodies carry `errors` as an object, 401 bodies carry `error`, `hint` and `error_description`
        def error_message(response, body)
          body = {} unless body.is_a?(Hash)
          errors = body["errors"].is_a?(Hash) ? body["errors"] : {}
          details = [errors["detail"], body["error"], body["hint"], body["error_description"]].compact_blank

          ["SinergiaCRM API error (HTTP #{response.status})", *details].join(": ")
        end

        def connection
          site = settings[:site]
          raise Error, "SinergiaCRM API is not configured" unless settings[:enabled] && site.present? && settings[:client_id].present? && settings[:client_secret].present?

          Faraday.new(
            url: "#{site.chomp("/")}/Api/",
            headers: { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" },
            request: { open_timeout: 10, timeout: 60 }
          )
        end

        def settings
          Decidim::Sinergiacrm.api
        end
      end
    end
  end
end
