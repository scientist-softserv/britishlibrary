# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin can select home page theme', type: :feature, js: true, clean: true do
  let(:account) { create(:account) }
  let(:admin) { create(:user).tap { |u| u.add_role(:admin, Site.instance) } }
  let(:user) { create :user }

  before do
    Site.update(account: account)
    login_as(admin)
  end

  # rubocop:disable RSpec/ScatteredLet, RSpec/LetSetup
  let!(:work) do
    create(:generic_work,
           title: ['Llamas and Alpacas'],
           keyword: ['llama', 'alpaca'],
           user: user)
  end

  # rubocop:enable RSpec/ScatteredLet, RSpec/LetSetup

  context "as a repository admin" do
    it "has a tab for themes on the appearance tab" do
      visit '/admin/appearance'
      expect(page).to have_content 'Appearance'
      click_link('Themes')
      expect(page).to have_content 'Home Page Theme'
    end

    it 'has a select box for the home, show, and search pages themes' do
      visit '/admin/appearance'
      click_link('Themes')
      select('BL Default Homepage', from: 'Home Page Theme')
      select('List view', from: 'Search Results Page Theme')
      select('Default Show Page', from: 'Show Page Theme')
      click_on('Save')
      expect(page).to have_content('The appearance was successfully updated')
    end

    it 'sets the theme to default if no theme is selected' do
      visit '/'
      expect(page).to have_css('body.default_home.list_view.default_show')
    end

    it 'sets the themes when the theme form is saved' do
      visit 'admin/appearance'
      click_link('Themes')
      select('BL Default Homepage', from: 'Home Page Theme')
      select('Gallery view', from: 'Search Results Page Theme')
      select('Default Show Page', from: 'Show Page Theme')
      click_on('Save')
      site = Site.last
      account.sites << site
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      expect(site.home_theme).to eq('default_home')
      expect(site.show_theme).to eq('default_show')
      expect(site.search_theme).to eq('gallery_view')
      visit '/'
      expect(page).to have_css('body.default_home.gallery_view.default_show')
    end
  end

  context 'when a search results theme is selected' do
    it 'updates the search results page with the selected layout view' do # rubocop:disable RSpec/ExampleLength
      visit '/admin/appearance'
      click_link('Themes')
      select('Gallery view', from: 'Search Results Page Theme')

      expect(page).to have_content('This will select a default view for the search results page. Users can select their preferred views on the search results page that will override this selection')

      click_on('Save')
      site = Site.last
      account.sites << site
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      expect(page).to have_content('The appearance was successfully updated')
      expect(site.search_theme).to eq('gallery_view')
      click_link('Themes')
      expect(page).to have_select('Search Results Page Theme', selected: 'Gallery view')
      visit '/'
      expect(page).to have_css('body.gallery_view')
      fill_in "search-field-header", with: "llama"
      click_button "search-submit-header"
      expect(page).to have_css('.row.gallery')
    end

    # TODO: temp skip until GroupAwareRoleChecker#has_group_aware_role? bug is resolved
    xit 'updates to the users preferred view' do
      login_as admin
      visit '/admin/appearance'
      click_link('Themes')
      select('Gallery view', from: 'Search Results Page Theme')
      find('body').click
      click_on('Save')
      site = Site.last
      account.sites << site
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      visit '/'
      fill_in "search-field-header", with: "llama"
      click_button "search-submit-header"
      expect(page).to have_css('.row.gallery')
      click_link "List"
      expect(page).to have_current_path('/catalog?locale=en&q=llama&search_field=all_fields&utf8=✓&view=list')
    end

    it 'defaults to list view when no theme is selected' do
      visit '/'
      fill_in "search-field-header", with: "llama"
      click_button "search-submit-header"
      expect(page).to have_current_path('/catalog?utf8=✓&search_field=all_fields&q=llama')
    end
  end

  context 'when a home page theme is selected' do
    it 'renders theme notes and wireframe' do
      login_as admin
      visit '/admin/appearance'
      click_link('Themes')
      select('BL Default Homepage', from: 'Home Page Theme')
      expect(page).to have_content('This theme uses a custom banner image')
      expect(page).to have_content('This theme uses marketing text')
      expect(page.find('#home-wireframe img')['src']).to match(%r{/assets\/themes\/default_home/})
    end

    it 'renders the partials in the theme folder' do
      login_as admin
      visit '/admin/appearance'
      click_link('Themes')
      select('BL Default Homepage', from: 'Home Page Theme')
      click_on('Save')
      site = Site.last
      account.sites << site
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      visit '/'
      expect(page).to have_css('body.default_home')
      expect(page).to have_css('nav.navbar.navbar-inverse.navbar-static-top.default-color')
    end

    it 'updates the home theme when the theme is changed' do # rubocop:disable RSpec/ExampleLength
      login_as admin
      visit '/admin/appearance'
      click_link('Themes')
      select('BL Default Homepage', from: 'Home Page Theme')
      click_on('Save')
      site = Site.last
      account.sites << site
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      visit '/'
      expect(page).to have_css('body.default_home')
      expect(page).to have_css('nav.navbar.navbar-inverse.navbar-static-top.default-color')
      visit '/admin/appearance'
      click_link('Themes')
      select('Non-Shared Site Homepage', from: 'Home Page Theme')
      click_on('Save')
      site = Site.last
      account.sites << site
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      visit '/'
      expect(page).to have_css('body.bl_non_shared_home')
      expect(page).not_to have_css('nav.navbar.navbar-inverse.navbar-static-topnon-shared-repo')
    end

    it 'renders the default partial if the theme partial is missing' do
      allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
      allow_any_instance_of(ApplicationController).to receive(:home_page_theme).and_return("missing_theme")
      visit '/'
      expect(page).to have_css('body.missing_theme')
      expect(page).not_to have_css('nav.cultural-repsitory-nav')
      expect(page).to have_css('nav.navbar.navbar-inverse.navbar-static-top')
    end
  end
end
