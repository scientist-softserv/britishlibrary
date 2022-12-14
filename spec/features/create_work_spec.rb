# frozen_string_literal: true

RSpec.describe 'Creating a new Work', :clean do
  let(:user) do
    u = create(:user)
    u.add_role(:depositor)
    u
  end

  before do
    AdminSet.find_or_create_default_admin_set_id
    login_as user, scope: :user
  end

  it 'creates the work' do
    skip 'Share your work button is removed for BL'
    visit '/'
    click_link "Share Your Work"
    expect(page).to have_button "Create work"
  end
end
