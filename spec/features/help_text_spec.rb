# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Help Text', type: :feature do
  let(:user) { create(:user) }
  let(:title) { 'A name to aid in identifying a work.' }
  let(:alternative_title) { 'Alternative title for the item, such as a translated or abbreviated form of the title.' }
  let(:resource_type) { 'Select the specific resource type that best describes the work.' }
  let(:collection) { 'NOT IN DEPOSIT FORM - BUT IS IN \'SHOW WORK\'' }
  let(:creator_name_type) { 'Select one' }
  let(:creator_isni) { 'Please enter the creator\'s ISNI, e.g. 0000 1234 5678 9101' }
  let(:creator_orcid) { 'Please enter the creator\'s ORCID e.g. 0000-1234-5678-9101' }
  let(:creator_family_name) { 'Please enter the creator\'s last name/family name.' }
  let(:creator_given_name) { 'Please enter the creator\'s first name/given name.' }
  let(:creator_organisational_name) { 'Please enter the organisation\'s name.' }
  let(:creator_ror) { 'Please enter the organisation\'s ROR ID, e.g. https://ror.org/05dhe8b71/ ' }
  let(:creator_grid) { 'Please enter the organisation\'s GRID, e.g. grid.36212.34' }
  let(:creator_wikidata) { 'Please enter the organisation\'s Wikidata ID, e.g. Q23308' }
  let(:creator_institutional_relationship) { 'Select one' }
  let(:contributor_name_type) { 'Select one' }
  let(:contributor_isni) { 'Please enter the contributor\'s ISNI, e.g. 0000 1234 5678 9101' }
  let(:contributor_orcid) { 'Please enter the creator\'s ORCID e.g. 0000-1234-5678-9101' }
  let(:contributor_family_name) { 'Please enter the contributor\'s last name/family name.' }
  let(:contributor_given_name) { 'Please enter the contributor\'s first name/given name.' }
  let(:contributor_organisation_name) { 'Please enter the organisation\'s name.' }
  let(:contributor_ror) { 'Please enter the organisation\'s ROR ID, e.g. 05dhe8b71' }
  let(:contributor_grid) { 'Please enter the organisation\'s GRID, e.g. grid.36212.34' }
  let(:contributor_wikidata) { 'Please enter the organisation\'s Wikidata ID, e.g. Q23308' }
  let(:contributor_role) { 'Please describe the contributor\'s role in this resource.' }
  let(:contributor_institutional_relationship) { 'Select one' }
  let(:abstract) { 'Please provide a short abstract or description of the item.' }
  let(:date_published) { 'The date the item was published and made publicly available. Provide just the year or a more specific date. If you are minting a DOI for this item, this field is mandatory.' }
  let(:material_media) { 'Describe the material and/or media of the item, e.g. drawing, sculpture, video' }
  let(:duration) { 'State the length of time the output lasts and the unit of measurement e.g. minutes.' }
  let(:institution) { 'The institution to which the item is affiliated.' }
  let(:organisational_unit) { 'The department, or unit, that the works sits within as per the organisational structure.' }
  let(:project_name) { 'The name of the project the work relates to, where relevant' }
  let(:funder) { 'Please start typing the funder\'s name, then select from the dropdown list' }
  let(:funder_doi) { 'Please enter the DOI' }
  let(:funder_isni) { 'Please enter the ISNI' }
  let(:funder_ror) { 'Please enter the ROR' }
  let(:funder_awards) { 'Please enter the award number' }
  let(:event_title) { 'The title of the conference, symposium or other event type.' }
  let(:series_name) { 'Please enter the series title, e.g. British Library Research Publications' }
  let(:editor_name_type) { 'Select one' }
  let(:editor_isni) { 'Please enter the editor\'s ISNI, e.g. 0000 1234 5678 9101' }
  let(:editor_orcid) { 'Please enter the editor\'s ORCID e.g. 0000-1234-5678-9101' }
  let(:editor_family_name) { 'Please enter the editor\'s last name/family name.' }
  let(:editor_given_name) { 'Please enter the editor\'s first name/given name.' }
  let(:editor_organisational_name) { 'Please enter the organisation\'s name.' }
  let(:editor_institutional_relationship) { 'Select one' }
  let(:journal_title) { 'Enter the journal title, e.g. Journal of Eighteenth-Century Studies.' }
  let(:alternative_journal_title) { 'Alternative title for the journal, such as a translated or abbreviated form of the title.' }
  let(:volume) { 'Please enter the number, e.g. 2, 76. Leave blank if there are no volumes.' }
  let(:edition) { 'For journals, specify the issue number (if available). For books/reports, if this is not the first edition, please specify in the format e.g. 2nd.' }
  let(:version) { 'The version number of the resource.\n\n If there are major changes then you must mint a new identifier e.g. DOI.' }
  let(:issue) { 'For journals, specify the issue number (if available). For books/reports, if this is not the first edition, please specify in the format e.g. 2nd.' }
  let(:pagination) { 'For a contribution or article, this can be the range of pages e.g. 1-13, for an entire volume it can be the total number of pages.' }
  let(:article_number) { 'If there is an article number, e.g. e0183455 (usually found in online-only journals)' }
  let(:publisher) { 'The name of the organisation making the work available.' }
  let(:place_of_publication) { 'Town/city and country, or country only, e.g. London, UK or UK' }
  let(:isbn) { 'ISBN for this item, if available.' }
  let(:issn) { 'Enter either the ISSN or the eISSN or both, if available.' }
  let(:eissn) { 'Enter either the ISSN or the eISSN or both, if available.' }
  let(:current_he_institution) { 'The current name of the HE institution responsible for the thesis. Select one.' }
  let(:he_institution_isni) { 'N/A' }
  let(:he_institution_ror) { 'N/A' }
  let(:date_accepted) { 'The date the item was accepted for publication. For example, this may be when receiving an acceptance letter from a publisher or when the final text has been copyedited and approved. You can provide just the year or a more specific date if you have this available.' }
  let(:date_submitted) { 'The date the item was submitted for review to the publisher. You can provide just the year or a more specific date if you have this available.' }
  let(:official_url) { 'Please enter the official URL, e.g. the publisher\'s link to the item.' }
  let(:related_url) { 'A link to a website or other specific content (audio, video, PDF document) related to the work. An example is the URL of a research project from which the work was derived.' }
  let(:related_exhibition) { 'If the work relates to an exhibition, please enter it here.' }
  let(:related_exhibition_venue) { 'The venue(s) that hosted the related exhibition.' }
  let(:related_exhibition_date) { 'Please enter the dates of the related exhibition, either a single or range of dates.' }
  let(:language) { 'Please provide the language.' }
  let(:licence) { 'Licensing and distribution information governing access to the work. Select from the provided drop-down list, or add to ‘additional information’ field below, if it is not included in the list. ' }
  let(:rights_statement) { 'Please select the most appropriate rights statement for the item.' }
  let(:rights_holder) { 'Please identify the rights holder if different from the creator.' }
  let(:doi) { 'A persistent digital object identifier, if your item already has one then enter this here in the following model e.g. 10.21250/tcq ' }
  let(:qualification_name) { 'The name of the qualification' }
  let(:qualification_level) { 'Select one' }
  let(:alternate_identifier) { 'May be used for local identifiers such as project codes, e.g. XTE12. Please include a prefix e.g. \'Project ID = XTE12\' to distinguish between multiple identifiers.' }
  let(:type_of_alternate_identifier) { 'State the type of alternate identifier.' }
  let(:related_identifier) { 'Globally unique identifiers, such as ISNI, ARK etc. For ISBN, ISSN and EISSN, use the separate fields.' }
  let(:type_of_related_identifier_type) { 'If you have listed a related identifier, then please select what type.' }
  let(:relationship_of_related_identifier) { 'If you have listed a related identifier, then state its relationship to the work, e.g. cites or continues the work.' }
  let(:peer_reviewed) { 'Please select if the item was peer-reviewed.' }
  let(:keywords) { 'Words or phrases you select to describe what the work is about. These are used to search for content.' }
  let(:dewey) { 'Enter the Dewey classmark' }
  let(:library_of_congress) { 'The letter code corresponding to the LCC - eg \'QK\' for \'Botany\' - see: https://en.wikipedia.org/wiki/Library_of_Congress_Classification' }
  let(:additional_information) { 'Please enter any additional information here that has not been entered. The information added in this field will be visible to everyone in the public view.' }

  before do
    site = Site.new
    account = Account.new
    allow(Site).to receive(:instance).and_return(site)
    allow(Site).to receive(:account).and_return(account)
  end

      # expect(page).to have_css(".#{work}_title p", text: title)
      # expect(page).to have_css(".#{work}_alt_title p", text: alternative_title)
      # expect(page).to have_css(".#{work}_resource_type p", text: resource_type)
      # expect(page).to have_css(".#{work}_creator_name_type option", text: creator_name_type)
      # expect(page).to have_css(".#{work}_creator_isni p", text: creator_isni)
      # expect(page).to have_css(".#{work}_creator_orcid p", text: creator_orcid)
      # expect(page).to have_css(".#{work}_creator_family_name p", text: creator_family_name)
      # expect(page).to have_css(".#{work}_creator_given_name p", text: creator_given_name)
      # expect(page).to have_css(".#{work}_creator_organisation p", text: creator_organisation)
      # expect(page).to have_css(".#{work}_creator_ror p", text: creator_ror)
      # expect(page).to have_css(".#{work}_creator_grid p", text: creator_grid)
      # expect(page).to have_css(".#{work}_wiki_page p", text: wiki_page)
      # expect(page).to have_css(".#{work}_creator_institutional_relationship option", text: creator_institutional_relationship)
      # expect(page).to have_css(".#{work}_contributor_name_type option", text: contributor_name_type)
      # expect(page).to have_css(".#{work}_contributor_isni p", text: contributor_isni)
      # expect(page).to have_css(".#{work}_contributor_orcid p", text: contributor_orcid)
      # expect(page).to have_css(".#{work}_contributor_family_name p", text: contributor_family_name)
      # expect(page).to have_css(".#{work}_contributor_given_name p", text: contributor_given_name)
      # expect(page).to have_css(".#{work}_contributor_organisation p", text: contributor_organisation)
      # expect(page).to have_css(".#{work}_contributor_ror p", text: contributor_ror)
      # expect(page).to have_css(".#{work}_contributor_grid p", text: contributor_grid)
      # expect(page).to have_css(".#{work}_contributor_wikidata p", text: contributor_wikidata)
      # expect(page).to have_css(".#{work}_contributor_role p", text: contributor_role)
      # expect(page).to have_css(".#{work}_contributor_institutional_relationship option", text: contributor_institutional_relationship)
      # expect(page).to have_css(".#{work}_abstract p", text: abstract)
      # expect(page).to have_css(".#{work}_date_published p", text: date_published)
      # expect(page).to have_css(".#{work}_material_media p", text: material_media)
      # expect(page).to have_css(".#{work}_duration p", text: duration)
      # expect(page).to have_css(".#{work}_institution p", text: institution)
      # expect(page).to have_css(".#{work}_organisational_unit p", text: organisational_unit)
      # expect(page).to have_css(".#{work}_project_name p", text: project_name)
      # expect(page).to have_css(".#{work}_funder p", text: funder)
      # expect(page).to have_css(".#{work}_funder_doi p", text: funder_doi)
      # expect(page).to have_css(".#{work}_funder_isni p", text: funder_isni)
      # expect(page).to have_css(".#{work}_funder_ror p", text: funder_ror)
      # expect(page).to have_css(".#{work}_funder_awards p", text: funder_awards)
      # expect(page).to have_css(".#{work}_event_title p", text: event_title)
      # expect(page).to have_css(".#{work}_event_location p", text: event_location)
      # expect(page).to have_css(".#{work}_event_date p", text: event_date)
      # expect(page).to have_css(".#{work}_series_name p", text: series_name)
      # expect(page).to have_css(".#{work}_book_title p", text: book_title)
      # expect(page).to have_css(".#{work}_editor_name_type option", text: editor_name_type)
      # expect(page).to have_css(".#{work}_editor_isni p", text: editor_isni)
      # expect(page).to have_css(".#{work}_editor_orcid p", text: editor_orcid)
      # expect(page).to have_css(".#{work}_editor_family_name p", text: editor_family_name)
      # expect(page).to have_css(".#{work}_editor_given_name p", text: editor_given_name)
      # expect(page).to have_css(".#{work}_editor_organisation_name p", text: editor_organisation_name)
      # expect(page).to have_css(".#{work}_editor_institutional_relationship option", text: editor_institutional_relationship)
      # expect(page).to have_css(".#{work}_journal_title p", text: journal_title)
      # expect(page).to have_css(".#{work}_alternative_journal_title p", text: alternative_journal_title)
      # expect(page).to have_css(".#{work}_volume p", text: volume)
      # expect(page).to have_css(".#{work}_edition p", text: edition)
      # expect(page).to have_css(".#{work}_version p", text: version)
      # expect(page).to have_css(".#{work}_issue p", text: issue)
      # expect(page).to have_css(".#{work}_pagination p", text: pagination)
      # expect(page).to have_css(".#{work}_article_number p", text: article_number)
      # expect(page).to have_css(".#{work}_publisher p", text: publisher)
      # expect(page).to have_css(".#{work}_place_of_publication p", text: place_of_publication)
      # expect(page).to have_css(".#{work}_isbn p", text: isbn)
      # expect(page).to have_css(".#{work}_issn p", text: issn)
      # expect(page).to have_css(".#{work}_eissn p", text: eissn)
      # expect(page).to have_css(".#{work}_current_he_institution p", text: current_he_institution)
      # expect(page).to have_css(".#{work}_he_institution_isni p", text: he_isniinstitution_isni)
      # expect(page).to have_css(".#{work}_he_institution_ror p", text: he_institution_ror)
      # expect(page).to have_css(".#{work}_date_accepted p", text: date_accepted)
      # expect(page).to have_css(".#{work}_date_submitted p", text: date_submitted)
      # expect(page).to have_css(".#{work}_official_url p", text: official_url)
      # expect(page).to have_css(".#{work}_related_url p", text: related_url)
      # expect(page).to have_css(".#{work}_related_exhibition p", text: related_exhibition)
      # expect(page).to have_css(".#{work}_related_exhibition_venue p", text: related_exhibition_venue)
      # expect(page).to have_css(".#{work}_related_exhibition_date p", text: related_exhibition_date)
      # expect(page).to have_css(".#{work}_language p", text: language)
      # expect(page).to have_css(".#{work}_license p", text: license)
      # expect(page).to have_css(".#{work}_rights_statement p", text: rights_statement)
      # expect(page).to have_css(".#{work}_rights_holder p", text: rights_holder)
      # expect(page).to have_css(".#{work}_doi p", text: doi)
      # expect(page).to have_css(".#{work}_qualification_name p", text: qualification_name)
      # expect(page).to have_css(".#{work}_qualification_level p", text: qualification_level)
      # expect(page).to have_css(".#{work}_alternate_identifier p", text: alternate_identifier)
      # expect(page).to have_css(".#{work}_type_of_alternate_identifier p", text: type_of_alternate_identifier)
      # expect(page).to have_css(".#{work}_related_identifier p", text: related_identifier)
      # expect(page).to have_css(".#{work}_type_of_related_identifier p", text: type_of_related_identifier)
      # expect(page).to have_css(".#{work}_relationship_of_related_identifier p", text: relationship_of_related_identifier)
      # expect(page).to have_css(".#{work}_peer_reviewed p", text: peer_reviewed)
      # expect(page).to have_css(".#{work}_keywords p", text: keywords)
      # expect(page).to have_css(".#{work}_dewey p", text: dewey)
      # expect(page).to have_css(".#{work}_library_of_congress p", text: library_of_congress)
      # expect(page).to have_css(".#{work}_additional_information p", text: additional_information)
  
  work = 'article'
  context work do
    before do
      login_as user
      visit "/concern/#{work}s/new#metadata"
    end

    it 'displays correct help text' do
      expect(page).to have_css(".#{work}_title p", text: title)
      expect(page).to have_css(".#{work}_alt_title p", text: alternative_title)
      expect(page).to have_css(".#{work}_resource_type p", text: resource_type)
      expect(page).to have_css(".#{work}_creator_name_type option", text: creator_name_type)
      expect(page.find(".#{work}_creator_isni input")['placeholder']).to eq creator_isni
      expect(page.find(".#{work}_creator_orcid input")['placeholder']).to eq creator_orcid
      # expect(page).to have_css(".#{work}_creator_orcid p", text: creator_orcid)
      # expect(page).to have_css(".#{work}_creator_family_name p", text: creator_family_name)
      # expect(page).to have_css(".#{work}_creator_given_name p", text: creator_given_name)
      # expect(page).to have_css(".#{work}_creator_organisation p", text: creator_organisation)
      # expect(page).to have_css(".#{work}_creator_ror p", text: creator_ror)
      # expect(page).to have_css(".#{work}_creator_grid p", text: creator_grid)
      # expect(page).to have_css(".#{work}_wiki_page p", text: wiki_page)
      # expect(page).to have_css(".#{work}_creator_institutional_relationship option", text: creator_institutional_relationship)
      # expect(page).to have_css(".#{work}_contributor_name_type option", text: contributor_name_type)
      # expect(page).to have_css(".#{work}_contributor_isni p", text: contributor_isni)
      # expect(page).to have_css(".#{work}_contributor_orcid p", text: contributor_orcid)
      # expect(page).to have_css(".#{work}_contributor_family_name p", text: contributor_family_name)
      # expect(page).to have_css(".#{work}_contributor_given_name p", text: contributor_given_name)
      # expect(page).to have_css(".#{work}_contributor_organisation p", text: contributor_organisation)
      # expect(page).to have_css(".#{work}_contributor_ror p", text: contributor_ror)
      # expect(page).to have_css(".#{work}_contributor_grid p", text: contributor_grid)
      # expect(page).to have_css(".#{work}_contributor_wikidata p", text: contributor_wikidata)
      # expect(page).to have_css(".#{work}_contributor_role p", text: contributor_role)
      # expect(page).to have_css(".#{work}_contributor_institutional_relationship option", text: contributor_institutional_relationship)
      # expect(page).to have_css(".#{work}_abstract p", text: abstract)
      # expect(page).to have_css(".#{work}_date_published p", text: date_published)
      # expect(page).to have_css(".#{work}_material_media p", text: material_media)
      # expect(page).to have_css(".#{work}_duration p", text: duration)
      # expect(page).to have_css(".#{work}_institution p", text: institution)
      # expect(page).to have_css(".#{work}_organisational_unit p", text: organisational_unit)
      # expect(page).to have_css(".#{work}_project_name p", text: project_name)
      # expect(page).to have_css(".#{work}_funder p", text: funder)
      # expect(page).to have_css(".#{work}_funder_doi p", text: funder_doi)
      # expect(page).to have_css(".#{work}_funder_isni p", text: funder_isni)
      # expect(page).to have_css(".#{work}_funder_ror p", text: funder_ror)
      # expect(page).to have_css(".#{work}_funder_awards p", text: funder_awards)
      # expect(page).to have_css(".#{work}_journal_title p", text: journal_title)
      # expect(page).to have_css(".#{work}_alternative_journal_title p", text: alternative_journal_title)
      # expect(page).to have_css(".#{work}_volume p", text: volume)
      # expect(page).to have_css(".#{work}_version p", text: version)
      # expect(page).to have_css(".#{work}_issue p", text: issue)
      # expect(page).to have_css(".#{work}_pagination p", text: pagination)
      # expect(page).to have_css(".#{work}_article_number p", text: article_number)
      # expect(page).to have_css(".#{work}_publisher p", text: publisher)
      # expect(page).to have_css(".#{work}_place_of_publication p", text: place_of_publication)
      # expect(page).to have_css(".#{work}_issn p", text: issn)
      # expect(page).to have_css(".#{work}_eissn p", text: eissn)
      # expect(page).to have_css(".#{work}_date_accepted p", text: date_accepted)
      # expect(page).to have_css(".#{work}_date_submitted p", text: date_submitted)
      # expect(page).to have_css(".#{work}_official_url p", text: official_url)
      # expect(page).to have_css(".#{work}_related_url p", text: related_url)
      # expect(page).to have_css(".#{work}_language p", text: language)
      # expect(page).to have_css(".#{work}_license p", text: license)
      # expect(page).to have_css(".#{work}_rights_statement p", text: rights_statement)
      # expect(page).to have_css(".#{work}_rights_holder p", text: rights_holder)
      # expect(page).to have_css(".#{work}_doi p", text: doi)
      # expect(page).to have_css(".#{work}_alternate_identifier p", text: alternate_identifier)
      # expect(page).to have_css(".#{work}_type_of_alternate_identifier p", text: type_of_alternate_identifier)
      # expect(page).to have_css(".#{work}_related_identifier p", text: related_identifier)
      # expect(page).to have_css(".#{work}_type_of_related_identifier p", text: type_of_related_identifier)
      # expect(page).to have_css(".#{work}_relationship_of_related_identifier p", text: relationship_of_related_identifier)
      # expect(page).to have_css(".#{work}_peer_reviewed p", text: peer_reviewed)
      # expect(page).to have_css(".#{work}_keywords p", text: keywords)
      # expect(page).to have_css(".#{work}_dewey p", text: dewey)
      # expect(page).to have_css(".#{work}_library_of_congress p", text: library_of_congress)
      # expect(page).to have_css(".#{work}_additional_information p", text: additional_information)
    end
  end

  # work = 'book_contribution'
  # context work do
  #   it 'displays correct help text' do
  #     visit "/concern/#{work}s/new#metadata"
  #     expect(page).to have_css(".#{work}_title p", text: title)
  #     expect(page).to have_css(".#{work}_alt_title p", text: alternative_title)
  #     expect(page).to have_css(".#{work}_resource_type p", text: resource_type)
  #     expect(page).to have_css(".#{work}_creator_name_type option", text: creator_name_type)
  #     expect(page).to have_css(".#{work}_creator_isni p", text: creator_isni)
  #     expect(page).to have_css(".#{work}_creator_orcid p", text: creator_orcid)
  #     expect(page).to have_css(".#{work}_creator_family_name p", text: creator_family_name)
  #     expect(page).to have_css(".#{work}_creator_given_name p", text: creator_given_name)
  #     expect(page).to have_css(".#{work}_creator_organisation p", text: creator_organisation)
  #     expect(page).to have_css(".#{work}_creator_ror p", text: creator_ror)
  #     expect(page).to have_css(".#{work}_creator_grid p", text: creator_grid)
  #     expect(page).to have_css(".#{work}_wiki_page p", text: wiki_page)
  #     expect(page).to have_css(".#{work}_creator_institutional_relationship option", text: creator_institutional_relationship)
  #     expect(page).to have_css(".#{work}_contributor_name_type option", text: contributor_name_type)
  #     expect(page).to have_css(".#{work}_contributor_isni p", text: contributor_isni)
  #     expect(page).to have_css(".#{work}_contributor_orcid p", text: contributor_orcid)
  #     expect(page).to have_css(".#{work}_contributor_family_name p", text: contributor_family_name)
  #     expect(page).to have_css(".#{work}_contributor_given_name p", text: contributor_given_name)
  #     expect(page).to have_css(".#{work}_contributor_organisation p", text: contributor_organisation)
  #     expect(page).to have_css(".#{work}_contributor_ror p", text: contributor_ror)
  #     expect(page).to have_css(".#{work}_contributor_grid p", text: contributor_grid)
  #     expect(page).to have_css(".#{work}_contributor_wikidata p", text: contributor_wikidata)
  #     expect(page).to have_css(".#{work}_contributor_role p", text: contributor_role)
  #     expect(page).to have_css(".#{work}_contributor_institutional_relationship option", text: contributor_institutional_relationship)
  #     expect(page).to have_css(".#{work}_abstract p", text: abstract)
  #     expect(page).to have_css(".#{work}_date_published p", text: date_published)
  #     expect(page).to have_css(".#{work}_institution p", text: institution)
  #     expect(page).to have_css(".#{work}_organisational_unit p", text: organisational_unit)
  #     expect(page).to have_css(".#{work}_project_name p", text: project_name)
  #     expect(page).to have_css(".#{work}_funder p", text: funder)
  #     expect(page).to have_css(".#{work}_funder_doi p", text: funder_doi)
  #     expect(page).to have_css(".#{work}_funder_isni p", text: funder_isni)
  #     expect(page).to have_css(".#{work}_funder_ror p", text: funder_ror)
  #     expect(page).to have_css(".#{work}_funder_awards p", text: funder_awards)
  #     expect(page).to have_css(".#{work}_series_name p", text: series_name)
  #     expect(page).to have_css(".#{work}_book_title p", text: book_title)
  #     expect(page).to have_css(".#{work}_editor_name_type option", text: editor_name_type)
  #     expect(page).to have_css(".#{work}_editor_isni p", text: editor_isni)
  #     expect(page).to have_css(".#{work}_editor_orcid p", text: editor_orcid)
  #     expect(page).to have_css(".#{work}_editor_family_name p", text: editor_family_name)
  #     expect(page).to have_css(".#{work}_editor_given_name p", text: editor_given_name)
  #     expect(page).to have_css(".#{work}_editor_organisation_name p", text: editor_organisation_name)
  #     expect(page).to have_css(".#{work}_editor_institutional_relationship option", text: editor_institutional_relationship)
  #     expect(page).to have_css(".#{work}_volume p", text: volume)
  #     expect(page).to have_css(".#{work}_edition p", text: edition)
  #     expect(page).to have_css(".#{work}_pagination p", text: pagination)
  #     expect(page).to have_css(".#{work}_publisher p", text: publisher)
  #     expect(page).to have_css(".#{work}_place_of_publication p", text: place_of_publication)
  #     expect(page).to have_css(".#{work}_isbn p", text: isbn)
  #     expect(page).to have_css(".#{work}_issn p", text: issn)
  #     expect(page).to have_css(".#{work}_eissn p", text: eissn)
  #     expect(page).to have_css(".#{work}_date_accepted p", text: date_accepted)
  #     expect(page).to have_css(".#{work}_date_submitted p", text: date_submitted)
  #     expect(page).to have_css(".#{work}_official_url p", text: official_url)
  #     expect(page).to have_css(".#{work}_related_url p", text: related_url)
  #     expect(page).to have_css(".#{work}_language p", text: language)
  #     expect(page).to have_css(".#{work}_license p", text: license)
  #     expect(page).to have_css(".#{work}_rights_statement p", text: rights_statement)
  #     expect(page).to have_css(".#{work}_rights_holder p", text: rights_holder)
  #     expect(page).to have_css(".#{work}_doi p", text: doi)
  #     expect(page).to have_css(".#{work}_alternate_identifier p", text: alternate_identifier)
  #     expect(page).to have_css(".#{work}_type_of_alternate_identifier p", text: type_of_alternate_identifier)
  #     expect(page).to have_css(".#{work}_related_identifier p", text: related_identifier)
  #     expect(page).to have_css(".#{work}_type_of_related_identifier p", text: type_of_related_identifier)
  #     expect(page).to have_css(".#{work}_relationship_of_related_identifier p", text: relationship_of_related_identifier)
  #     expect(page).to have_css(".#{work}_peer_reviewed p", text: peer_reviewed)
  #     expect(page).to have_css(".#{work}_keywords p", text: keywords)
  #     expect(page).to have_css(".#{work}_dewey p", text: dewey)
  #     expect(page).to have_css(".#{work}_library_of_congress p", text: library_of_congress)
  #     expect(page).to have_css(".#{work}_additional_information p", text: additional_information)
  #   end
  # end

  # work = 'book'
  # context work do
  #   it 'displays correct help text' do
      # expect(page).to have_css(".#{work}_title p", text: title)
      # expect(page).to have_css(".#{work}_alt_title p", text: alternative_title)
      # expect(page).to have_css(".#{work}_resource_type p", text: resource_type)
      # expect(page).to have_css(".#{work}_creator_name_type option", text: creator_name_type)
      # expect(page).to have_css(".#{work}_creator_isni p", text: creator_isni)
      # expect(page).to have_css(".#{work}_creator_orcid p", text: creator_orcid)
      # expect(page).to have_css(".#{work}_creator_family_name p", text: creator_family_name)
      # expect(page).to have_css(".#{work}_creator_given_name p", text: creator_given_name)
      # expect(page).to have_css(".#{work}_creator_organisation p", text: creator_organisation)
      # expect(page).to have_css(".#{work}_creator_ror p", text: creator_ror)
      # expect(page).to have_css(".#{work}_creator_grid p", text: creator_grid)
      # expect(page).to have_css(".#{work}_wiki_page p", text: wiki_page)
      # expect(page).to have_css(".#{work}_creator_institutional_relationship option", text: creator_institutional_relationship)
      # expect(page).to have_css(".#{work}_contributor_name_type option", text: contributor_name_type)
      # expect(page).to have_css(".#{work}_contributor_isni p", text: contributor_isni)
      # expect(page).to have_css(".#{work}_contributor_orcid p", text: contributor_orcid)
      # expect(page).to have_css(".#{work}_contributor_family_name p", text: contributor_family_name)
      # expect(page).to have_css(".#{work}_contributor_given_name p", text: contributor_given_name)
      # expect(page).to have_css(".#{work}_contributor_organisation p", text: contributor_organisation)
      # expect(page).to have_css(".#{work}_contributor_ror p", text: contributor_ror)
      # expect(page).to have_css(".#{work}_contributor_grid p", text: contributor_grid)
      # expect(page).to have_css(".#{work}_contributor_wikidata p", text: contributor_wikidata)
      # expect(page).to have_css(".#{work}_contributor_role p", text: contributor_role)
      # expect(page).to have_css(".#{work}_contributor_institutional_relationship option", text: contributor_institutional_relationship)
      # expect(page).to have_css(".#{work}_abstract p", text: abstract)
      # expect(page).to have_css(".#{work}_date_published p", text: date_published)
      # expect(page).to have_css(".#{work}_material_media p", text: material_media)
      # expect(page).to have_css(".#{work}_duration p", text: duration)
      # expect(page).to have_css(".#{work}_institution p", text: institution)
      # expect(page).to have_css(".#{work}_organisational_unit p", text: organisational_unit)
      # expect(page).to have_css(".#{work}_project_name p", text: project_name)
      # expect(page).to have_css(".#{work}_funder p", text: funder)
      # expect(page).to have_css(".#{work}_funder_doi p", text: funder_doi)
      # expect(page).to have_css(".#{work}_funder_isni p", text: funder_isni)
      # expect(page).to have_css(".#{work}_funder_ror p", text: funder_ror)
      # expect(page).to have_css(".#{work}_funder_awards p", text: funder_awards)
      # expect(page).to have_css(".#{work}_event_title p", text: event_title)
      # expect(page).to have_css(".#{work}_event_location p", text: event_location)
      # expect(page).to have_css(".#{work}_event_date p", text: event_date)
      # expect(page).to have_css(".#{work}_series_name p", text: series_name)
      # expect(page).to have_css(".#{work}_book_title p", text: book_title)
      # expect(page).to have_css(".#{work}_editor_name_type option", text: editor_name_type)
      # expect(page).to have_css(".#{work}_editor_isni p", text: editor_isni)
      # expect(page).to have_css(".#{work}_editor_orcid p", text: editor_orcid)
      # expect(page).to have_css(".#{work}_editor_family_name p", text: editor_family_name)
      # expect(page).to have_css(".#{work}_editor_given_name p", text: editor_given_name)
      # expect(page).to have_css(".#{work}_editor_organisation_name p", text: editor_organisation_name)
      # expect(page).to have_css(".#{work}_editor_institutional_relationship option", text: editor_institutional_relationship)
      # expect(page).to have_css(".#{work}_journal_title p", text: journal_title)
      # expect(page).to have_css(".#{work}_alternative_journal_title p", text: alternative_journal_title)
      # expect(page).to have_css(".#{work}_volume p", text: volume)
      # expect(page).to have_css(".#{work}_edition p", text: edition)
      # expect(page).to have_css(".#{work}_version p", text: version)
      # expect(page).to have_css(".#{work}_issue p", text: issue)
      # expect(page).to have_css(".#{work}_pagination p", text: pagination)
      # expect(page).to have_css(".#{work}_article_number p", text: article_number)
      # expect(page).to have_css(".#{work}_publisher p", text: publisher)
      # expect(page).to have_css(".#{work}_place_of_publication p", text: place_of_publication)
      # expect(page).to have_css(".#{work}_isbn p", text: isbn)
      # expect(page).to have_css(".#{work}_issn p", text: issn)
      # expect(page).to have_css(".#{work}_eissn p", text: eissn)
      # expect(page).to have_css(".#{work}_current_he_institution p", text: current_he_institution)
      # expect(page).to have_css(".#{work}_he_institution_isni p", text: he_isniinstitution_isni)
      # expect(page).to have_css(".#{work}_he_institution_ror p", text: he_institution_ror)
      # expect(page).to have_css(".#{work}_date_accepted p", text: date_accepted)
      # expect(page).to have_css(".#{work}_date_submitted p", text: date_submitted)
      # expect(page).to have_css(".#{work}_official_url p", text: official_url)
      # expect(page).to have_css(".#{work}_related_url p", text: related_url)
      # expect(page).to have_css(".#{work}_related_exhibition p", text: related_exhibition)
      # expect(page).to have_css(".#{work}_related_exhibition_venue p", text: related_exhibition_venue)
      # expect(page).to have_css(".#{work}_related_exhibition_date p", text: related_exhibition_date)
      # expect(page).to have_css(".#{work}_language p", text: language)
      # expect(page).to have_css(".#{work}_license p", text: license)
      # expect(page).to have_css(".#{work}_rights_statement p", text: rights_statement)
      # expect(page).to have_css(".#{work}_rights_holder p", text: rights_holder)
      # expect(page).to have_css(".#{work}_doi p", text: doi)
      # expect(page).to have_css(".#{work}_qualification_name p", text: qualification_name)
      # expect(page).to have_css(".#{work}_qualification_level p", text: qualification_level)
      # expect(page).to have_css(".#{work}_alternate_identifier p", text: alternate_identifier)
      # expect(page).to have_css(".#{work}_type_of_alternate_identifier p", text: type_of_alternate_identifier)
      # expect(page).to have_css(".#{work}_related_identifier p", text: related_identifier)
      # expect(page).to have_css(".#{work}_type_of_related_identifier p", text: type_of_related_identifier)
      # expect(page).to have_css(".#{work}_relationship_of_related_identifier p", text: relationship_of_related_identifier)
      # expect(page).to have_css(".#{work}_peer_reviewed p", text: peer_reviewed)
      # expect(page).to have_css(".#{work}_keywords p", text: keywords)
      # expect(page).to have_css(".#{work}_dewey p", text: dewey)
      # expect(page).to have_css(".#{work}_library_of_congress p", text: library_of_congress)
      # expect(page).to have_css(".#{work}_additional_information p", text: additional_information)
    # end
  # end
end
