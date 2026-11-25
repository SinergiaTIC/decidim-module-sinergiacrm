# frozen_string_literal: true

require "spec_helper"

describe "Login" do
  let(:organization) { create(:organization, name: { en: "Ateneu BCN" }) }
  let(:override_login) { false }
  let(:portal_id) { "8d0b5c1e-4f0a-4d4e-9c55-1f6d2a7b3c10" }
  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: "sinergia_crm",
      uid: "Contacts:#{portal_id}",
      info: { email: "john@example.org" },
      extra: { raw_info: { portal_id:, portal_type: "Contacts", user: { id: portal_id, email: "john@example.org" } } }
    )
  end

  before do
    allow(Decidim::Sinergiacrm).to receive(:override_login).and_return(override_login)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:sinergia_crm] = omniauth_hash
    OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)

    switch_to_host(organization.host)
    visit decidim.new_user_session_path
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:sinergia_crm] = nil
  end

  shared_examples "logs in with SinergiaCRM" do
    it "asks to complete the profile and creates the user" do
      click_on "Log in with SinergiaCRM"

      expect(page).to have_content("Please complete your profile")
      expect(page).to have_field("Your email", with: "john@example.org")

      within "#omniauth-register-form" do
        fill_in "Your name", with: "John Doe"
        # Decidim fails to create the user when the nickname is left empty
        fill_in "Nickname", with: "john_doe"
        check :registration_user_tos_agreement
        check :registration_user_newsletter
        click_on "Complete profile"
      end

      expect(page).to have_no_css("#omniauth-register-form")
      expect(page).to have_content("A message with a confirmation link has been sent to your email address")
      expect(Decidim::User.last.identities.pluck(:provider, :uid)).to eq([["sinergia_crm", "Contacts:#{portal_id}"]])
    end
  end

  context "when the login is not overridden" do
    it "shows the standard login with the provider icon" do
      expect(page).to have_css("a.login__omniauth-button--sinergia img.external-icon")
      expect(page).to have_css("a.login__omniauth-button--sinergia span.sr-only", text: "Log in with SinergiaCRM")
      expect(page).to have_field("Email")
      expect(page).to have_no_content("you must use your Ateneu BCN account")
      expect(page).to have_no_button("Administration access")
    end

    it_behaves_like "logs in with SinergiaCRM"
  end

  context "when the login is overridden" do
    let(:override_login) { true }
    let!(:admin) { create(:user, :admin, :confirmed, organization:, password: "decidim123456789") }

    it "shows the big button and hides the standard form" do
      expect(page).to have_content("To access the platform as a participant you must use your Ateneu BCN account")
      expect(page).to have_link("Log in with SinergiaCRM")
      expect(page).to have_no_css("a.login__omniauth-button--sinergia span.sr-only")
      expect(page).to have_no_field("Email")
      expect(page).to have_no_css(".login__omniauth-separator")
    end

    it "allows admins to log in with the standard form" do
      click_on "Administration access"

      within "#session_new_user" do
        fill_in "Email", with: admin.email
        fill_in "Password", with: "decidim123456789"
        click_on "Log in"
      end

      expect(page).to have_content("Logged in successfully")
    end

    it_behaves_like "logs in with SinergiaCRM"

    context "when the login modal is shown" do
      before do
        visit decidim.root_path
        page.execute_script("window.Decidim.currentDialogs.loginModal.open()")
      end

      it "only offers the SinergiaCRM button" do
        within "#loginModal" do
          expect(page).to have_link("Log in with SinergiaCRM")
          expect(page).to have_no_field("Email")
          expect(page).to have_no_button("Log in")
        end
      end
    end
  end
end
