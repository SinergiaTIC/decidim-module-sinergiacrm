# frozen_string_literal: true

# Stubs the SinergiaCRM API V8 with the fixtures in spec/fixtures/files/sinergiacrm_api:
# the token endpoint, two pages of stic_Contacts_Relationships, one page of Project
# and the field definitions of stic_Contacts_Relationships (with option items).
# The fixtures keep the keys and value formats of real responses, with fake values.
shared_context "with stubbed SinergiaCRM API" do
  let(:sinergiacrm_api_url) { "#{Decidim::Sinergiacrm.api[:site].chomp("/")}/Api" }
  let(:sinergiacrm_api_headers) { { "Content-Type" => "application/vnd.api+json" } }

  def sinergiacrm_api_fixture(name)
    file_fixture("sinergiacrm_api/#{name}.json").read
  end

  def stub_sinergiacrm_api_page(module_name, page, fixture, status: 200)
    stub_request(:get, "#{sinergiacrm_api_url}/V8/module/#{module_name}")
      .with(query: { page: { number: page.to_s, size: Decidim::Sinergiacrm.api[:page_size].to_s } })
      .to_return(status:, body: sinergiacrm_api_fixture(fixture), headers: sinergiacrm_api_headers)
  end

  let!(:sinergiacrm_token_request) do
    stub_request(:post, "#{sinergiacrm_api_url}/access_token")
      .to_return(status: 200, body: sinergiacrm_api_fixture("access_token"), headers: { "Content-Type" => "application/json; charset=UTF-8" })
  end
  let!(:sinergiacrm_fields_request) do
    stub_request(:get, "#{sinergiacrm_api_url}/V8/meta/fields/stic_Contacts_Relationships")
      .to_return(status: 200, body: sinergiacrm_api_fixture("stic_contacts_relationships_fields"), headers: sinergiacrm_api_headers)
  end

  before do
    stub_sinergiacrm_api_page("stic_Contacts_Relationships", 1, "stic_contacts_relationships_page_1")
    stub_sinergiacrm_api_page("stic_Contacts_Relationships", 2, "stic_contacts_relationships_page_2")
    stub_sinergiacrm_api_page("Project", 1, "project_page_1")
  end
end
