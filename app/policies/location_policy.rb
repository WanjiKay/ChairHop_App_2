class LocationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.stylist?
  end

  def update?
    user.stylist? && record.user_id == user.id
  end

  def destroy?
    user.stylist? && record.user_id == user.id
  end
end
