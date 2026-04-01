class ConversationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? &&
      (record.customer_id == user.id || record.stylist_id == user.id)
  end

  def create?
    user.present? && record.customer_id == user.id
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(customer_id: user.id).or(scope.where(stylist_id: user.id))
    end
  end
end
