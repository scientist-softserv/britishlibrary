# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'autofilling the form from DOI', js: true do
  include Warden::Test::Helpers

  let(:model_class) do
    Class.new(Article) do
      include Hyrax::DOI::DOIBehavior
      include Hyrax::DOI::DataCiteDOIBehavior
    end
  end
  let(:form_class) do
    Class.new(Hyrax::ArticleForm) do
      include Hyrax::DOI::DOIFormBehavior
      include Hyrax::DOI::DataCiteDOIFormBehavior

      self.model_class = Article
    end
  end
  let(:helper_module) do
    Module.new do
      include ::BlacklightHelper
      include Hyrax::BlacklightOverride
      include Hyrax::HyraxHelperBehavior
      include Hyrax::DOI::HelperBehavior
    end
  end
  let(:solr_document_class) do
    Class.new(SolrDocument) do
      include Hyrax::DOI::SolrDocument::DOIBehavior
      include Hyrax::DOI::SolrDocument::DataCiteDOIBehavior
    end
  end
  let(:controller_class) do
    Class.new(::ApplicationController) do
      # Adds Hyrax behaviors to the controller.
      include Hyrax::WorksControllerBehavior
      include Hyrax::BreadcrumbsForWorks
      self.curation_concern_type = Article

      # Use this line if you want to use a custom presenter
      self.show_presenter = Hyrax::ArticlePresenter

      helper Hyrax::DOI::Engine.helpers
    end
  end

  let(:username) { ENV['DATACITE_USERNAME'] }
  let(:password) { ENV['DATACITE_PASSWORD'] }
  let(:prefix) { ENV['DATACITE_PREFIX'] }

  let(:user) { FactoryBot.create(:admin) }
  let(:input) { File.join(Hyrax::DOI::Engine.root, 'spec', 'fixtures', 'datacite.json') }
  let(:metadata) { Bolognese::Metadata.new(input: input) }
  # Findable DOI must be present in DataCite Fabrica Test
  let(:findable_doi) { "#{prefix}/xp2c-zk51" }

  before do
    # Override test app classes and module to simulate generators having been run
    stub_const("Article", model_class)
    stub_const("Hyrax::ArticleForm", form_class)
    stub_const("HyraxHelper", helper_module)
    stub_const("SolrDocument", solr_document_class)
    stub_const("Hyrax::ArticlesController", controller_class)

    # Mock Bolognese so it doesn't have to make a network request
    allow(Bolognese::Metadata).to receive(:new).and_return(metadata)

    allow_any_instance_of(Ability).to receive(:admin_set_with_deposit?).and_return(true)
    allow_any_instance_of(Ability).to receive(:can?).and_call_original
    allow_any_instance_of(Ability).to receive(:can?).with(:new, anything).and_return(true)

    login_as user
  end

  it 'autofills the form' do
    visit "/concern/articles/new"
    fill_in 'article_doi', with: findable_doi
    text = accept_confirm do
      click_link "doi-autofill-btn"
    end
    expect(text).to eq('This operation is destructive and will replace any information already filled in on this form.')

    accept_alert "Form fields autofilled"

    click_link 'Descriptions'
    expect(page).to have_field('article_title', with: 'Test DOI ')
    expect(page).to have_field('article_creator', with: 'Bradford, Lea Ann')
    expect(page).to have_field('article_publisher', with: 'Random')
    expect(page).to have_field('article_date_created', with: '2000')

    # expect page to have forwarded to metadata tab
    expect(URI.parse(page.current_url).fragment).to eq 'metadata'
  end
end
