class ReviewPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    user.present? && record.appointment.customer == user
  end

  def edit?
    record.customer == user && record.editable?
  end

  def update?
    record.customer == user && record.editable?
  end

  def destroy?
    false
  end
end
