# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    transient do
      user { FactoryBot.create(:user) }
    end

    title { ["Test book"] }

    factory :book_with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryBot.create(:file_set,
                                                  user: evaluator.user,
                                                  title: ['A Contained Generic File'])
      end
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user)
    end
  end
end
