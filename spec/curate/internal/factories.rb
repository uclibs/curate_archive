# This is hear because it cannot be part of spec_support as other
# Curate based apps would very likely register a :user
FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "email-#{srand}@test.com" }
    waived_welcome_page true
    sequence(:first_name) {|n| "First #{n}" }
    sequence(:last_name) {|n| "Last #{n}" }
    user_does_not_require_profile_update true
    password 'a password'
    password_confirmation 'a password'
    sign_in_count 20
  end

  factory :account do
    user { FactoryGirl.build(:user) }
    sequence(:email) {|n| "email-#{srand}@test.com" }
    initialize_with {|*args|
      new( user )
    }
    after(:create) do |account, evaluator|
      account.save
    end
  end
end
