class ServicePolicy < ApplicationPolicy
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
    user.stylist? && record.stylist == user
  end

  def destroy?
    user.stylist? && record.stylist == user
  end
end
