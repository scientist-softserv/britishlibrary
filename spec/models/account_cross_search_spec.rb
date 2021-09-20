require 'rails_helper'

RSpec.describe AccountCrossSearch, type: :model do
  it do
    should belong_to(:full_account).
      class_name('Account')

    should belong_to(:search_account).
      class_name('Account')
  end
end
