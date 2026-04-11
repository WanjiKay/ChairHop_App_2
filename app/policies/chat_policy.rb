class ChatPolicy < ApplicationPolicy
  def show?
    record.customer == user
  end

  def create?
    user.present?
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(customer: user)
    end
  end
end
