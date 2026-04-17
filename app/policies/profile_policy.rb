class ProfilePolicy < ApplicationPolicy
  def apply_hopps_bio?
    user.stylist?
  end
end
