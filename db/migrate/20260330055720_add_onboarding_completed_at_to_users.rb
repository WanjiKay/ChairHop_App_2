class AddOnboardingCompletedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :onboarding_completed_at, :datetime
  end
end
