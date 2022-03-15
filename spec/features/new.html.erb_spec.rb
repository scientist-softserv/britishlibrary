# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'views/hyrax/contact_form/new', type: :feature do
  let(:user) { User.create }
  let(:dropdown) { 'contact_form_category' }
  let(:selection) { 'Depositing content' }
  let(:f_name) { 'contact_form_name' }
  let(:f_email) { 'contact_form_email' }
  let(:f_subject) { 'contact_form_subject' }
  let(:f_message) { 'contact_form_message' }
  let(:f_button) { 'Send' }
  let(:test_name) { 'Kirk Tester' }
  let(:test_email) { 'kirk@tester.com' }
  let(:test_subject) { 'Kirk Form Testing' }
  let(:test_message) { 'I am trying to test this.' }
  let(:button_css) { 'input.btn.btn-primary.devise-button' }

  before do
    site = Site.new
    account = Account.new
    allow(Site).to receive(:instance).and_return(site)
    allow(Site).to receive(:account).and_return(account)
    visit '/contact'
  end

  describe 'contact form with styled button' do
    it 'succeeds with valid attributes' do
      expect(page).to have_content 'Contact Form'
      expect(page).to have_css button_css
      select selection, from: dropdown
      fill_in f_name, with: test_name
      fill_in f_email, with: test_email
      fill_in f_subject, with: test_subject
      fill_in f_message, with: test_message
      click_button f_button
      expect(page).to have_content 'Thank you for your message!'
      expect(page).to have_css button_css
    end

    it 'fails with an invalid email' do
      select selection, from: dropdown
      fill_in f_name, with: test_name
      fill_in f_email, with: test_email.delete('@')
      fill_in f_subject, with: test_subject
      fill_in f_message, with: test_message
      click_button f_button
      expect(page).to have_content 'Sorry, this message was not delivered.'
      expect(page).to have_field(f_subject, with: test_subject)
      expect(page).to have_field(f_message, with: test_message)
      expect(page).to have_css button_css
    end
  end

  describe 'as a logged in user' do
    before do
      login_as user
      visit '/contact'
    end

    it 'prefills the name and email fields' do
      expect(page).to have_field(f_name, with: user.name)
      expect(page).to have_field(f_email, with: user.email)
    end
  end
end