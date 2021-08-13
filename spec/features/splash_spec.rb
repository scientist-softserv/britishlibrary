# frozen_string_literal: true

RSpec.describe "The splash page", multitenant: true do
  around do |example|
    default_host = Capybara.default_host
    Capybara.default_host = Capybara.app_host || "http://#{Account.admin_host}"
    example.run
    Capybara.default_host = default_host
  end

  # OVERRIDE: updated specs to match BL theming
  it "shows the page, displaying Shared Research Repository header" do
    visit '/'
    expect(page).to have_link 'Admin', href: main_app.new_user_session_path(locale: 'en')

    within 'footer' do
      expect(page).to have_link 'Admin'
    end

    expect(page).to have_content("Shared Research Repository")
  end
end
