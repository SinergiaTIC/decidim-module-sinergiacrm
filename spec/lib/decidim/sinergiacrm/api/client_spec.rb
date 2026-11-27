# frozen_string_literal: true

require "spec_helper"

module Decidim::Sinergiacrm::Api
  describe Client do
    subject(:client) { described_class.new }

    include_context "with stubbed SinergiaCRM API"

    let(:cache) { ActiveSupport::Cache::MemoryStore.new }
    let(:api_settings) { Decidim::Sinergiacrm.api }
    let(:relationships_url) { "#{sinergiacrm_api_url}/V8/module/stic_Contacts_Relationships" }
    let(:fields_url) { "#{sinergiacrm_api_url}/V8/meta/fields/stic_Contacts_Relationships" }
    let(:any_relationships_page) { stub_request(:get, relationships_url).with(query: hash_including({})) }

    before do
      allow(Rails).to receive(:cache).and_return(cache)
      allow(Decidim::Sinergiacrm).to receive(:api).and_return(api_settings)
    end

    describe "access token" do
      before { client.records("stic_Contacts_Relationships", page: 1) }

      it "requests it with client credentials as JSON" do
        expect(
          a_request(:post, "#{sinergiacrm_api_url}/access_token").with(
            body: { grant_type: "client_credentials", client_id: api_settings[:client_id], client_secret: api_settings[:client_secret] }.to_json,
            headers: { "Content-Type" => "application/vnd.api+json", "Accept" => "application/vnd.api+json" }
          )
        ).to have_been_made.once
      end

      it "sends it as a bearer token" do
        expect(
          a_request(:get, relationships_url).with(
            query: hash_including({}),
            headers: { "Authorization" => "Bearer fake-sinergiacrm-access-token", "Accept" => "application/vnd.api+json" }
          )
        ).to have_been_made
      end

      it "caches it" do
        described_class.new.fields("stic_Contacts_Relationships")

        expect(sinergiacrm_token_request).to have_been_made.once
      end

      it "requests a new one a minute before it expires" do
        travel 59.minutes + 1.second
        described_class.new.fields("stic_Contacts_Relationships")

        expect(sinergiacrm_token_request).to have_been_made.twice
      end

      context "when the token lives a minute or less" do
        let!(:sinergiacrm_token_request) do
          stub_request(:post, "#{sinergiacrm_api_url}/access_token").to_return(status: 200, body: { access_token: "short-lived", expires_in: 60 }.to_json)
        end

        it "does not cache it" do
          described_class.new.fields("stic_Contacts_Relationships")

          expect(sinergiacrm_token_request).to have_been_made.twice
        end
      end

      context "when the site has a trailing slash" do
        let(:api_settings) { Decidim::Sinergiacrm.api.merge(site: "#{Decidim::Sinergiacrm.api[:site]}/") }

        it "builds the same URLs" do
          expect(sinergiacrm_token_request).to have_been_made.once
          expect(a_request(:get, relationships_url).with(query: hash_including({}))).to have_been_made.once
        end
      end
    end

    describe "#records" do
      let(:page) { client.records("stic_Contacts_Relationships", page: 1) }

      it "sends the page number and size" do
        page

        expect(a_request(:get, relationships_url).with(query: { page: { number: "1", size: api_settings[:page_size].to_s } })).to have_been_made.once
      end

      it "returns the records and the total pages" do
        expect(page[:total_pages]).to eq(2)
        expect(page[:records].pluck("id")).to eq(%w(a1b2c3d4-0001-4000-8000-000000000001 a1b2c3d4-0002-4000-8000-000000000002))
        expect(page[:records].first["attributes"]).to include("relationship_type" => "member", "active" => "1")
      end

      context "when the page is past the end" do
        before { any_relationships_page.to_return(status: 200, body: sinergiacrm_api_fixture("empty_page")) }

        it "returns no records and zero total pages" do
          expect(page).to eq(records: [], total_pages: 0)
        end
      end

      context "when records come without the total pages" do
        before do
          body = JSON.parse(sinergiacrm_api_fixture("stic_contacts_relationships_page_1")).except("meta")
          any_relationships_page.to_return(status: 200, body: body.to_json)
        end

        it "raises an unexpected response error" do
          expect { page }.to raise_error(Error, "SinergiaCRM API returned records without the total pages")
        end
      end

      [{ data: { id: "1" } }, { data: [], meta: [] }].each do |body|
        context "when the response is #{body.to_json}" do
          before { any_relationships_page.to_return(status: 200, body: body.to_json) }

          it "raises an unexpected response error" do
            expect { page }.to raise_error(Error, "SinergiaCRM API returned an unexpected response")
          end
        end
      end
    end

    describe "#fields" do
      it "returns the field definitions" do
        expect(client.fields("stic_Contacts_Relationships")["relationship_type"]).to include("type" => "enum", "option_items" => include("member" => "Member"))
      end

      it "returns nothing when the response has no field definitions" do
        stub_request(:get, fields_url).to_return(status: 200, body: { data: [] }.to_json, headers: sinergiacrm_api_headers)

        expect(client.fields("stic_Contacts_Relationships")).to eq({})
      end

      it "ignores the entries that are not field definitions" do
        body = { data: { attributes: { name: { type: "varchar" }, broken: "text" } } }
        stub_request(:get, fields_url).to_return(status: 200, body: body.to_json, headers: sinergiacrm_api_headers)

        expect(client.fields("stic_Contacts_Relationships")).to eq("name" => { "type" => "varchar" })
      end
    end

    describe "errors" do
      let(:records) { client.records("stic_Contacts_Relationships", page: 1) }

      context "when the API returns 400" do
        before { stub_sinergiacrm_api_page("stic_Contacts_Relationships", 1, "error_400", status: 400) }

        it "raises with the error detail" do
          expect { records }.to raise_error(Error, "SinergiaCRM API error (HTTP 400): Module Foo does not exist")
        end
      end

      context "when the API returns 401" do
        before do
          client.fields("stic_Contacts_Relationships")
          stub_sinergiacrm_api_page("stic_Contacts_Relationships", 1, "error_401", status: 401)
        end

        it "raises with the error and hint" do
          expect { records }.to raise_error(Error, /HTTP 401.*access_denied.*Access token could not be verified/)
        end

        it "removes the cached token" do
          expect { records }.to raise_error(Error)
          client.fields("stic_Contacts_Relationships")

          expect(sinergiacrm_token_request).to have_been_made.twice
        end
      end

      context "when the token request fails" do
        before { stub_request(:post, "#{sinergiacrm_api_url}/access_token").to_return(status: 401, body: sinergiacrm_api_fixture("error_401")) }

        it "raises with the status" do
          expect { records }.to raise_error(Error, /HTTP 401/)
        end
      end

      context "when the token response has no access_token" do
        before { stub_request(:post, "#{sinergiacrm_api_url}/access_token").to_return(status: 200, body: { expires_in: 3600 }.to_json) }

        it "raises a missing token error" do
          expect { records }.to raise_error(Error, "SinergiaCRM API token response has no access_token")
        end
      end

      context "when the server returns a non JSON error" do
        before { any_relationships_page.to_return(status: 502, body: "<html>Bad Gateway</html>") }

        it "raises with the status" do
          expect { records }.to raise_error(Error, "SinergiaCRM API error (HTTP 502)")
        end
      end

      context "when a successful response is not JSON" do
        before { any_relationships_page.to_return(status: 200, body: "<html></html>") }

        it "raises an unparsable response error" do
          expect { records }.to raise_error(Error, /unparsable/)
        end
      end

      context "when the connection fails" do
        before { any_relationships_page.to_raise(Faraday::ConnectionFailed.new("Connection refused")) }

        it "raises a request failed error with the cause" do
          expect { records }.to raise_error(Error, /Connection refused/)
        end
      end

      context "when the request times out" do
        before { any_relationships_page.to_timeout }

        it "raises a request failed error" do
          expect { records }.to raise_error(Error, /request failed/)
        end
      end

      [{ enabled: false }, { site: "" }, { client_id: nil }, { client_secret: "" }].each do |override|
        context "when the API settings have #{override.keys.first} #{override.values.first.inspect}" do
          let(:api_settings) { Decidim::Sinergiacrm.api.merge(override) }

          it "raises a not configured error without calling the API" do
            expect { records }.to raise_error(Error, "SinergiaCRM API is not configured")
            expect(sinergiacrm_token_request).not_to have_been_made
          end
        end
      end
    end
  end
end
