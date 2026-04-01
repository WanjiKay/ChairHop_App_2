class AppointmentPolicy < ApplicationPolicy
  # Anyone can view the index of available (pending) appointments
  def index?
    true
  end

  # Anyone (including guests) can view pending appointments; parties can view their own
  def show?
    return true if record.pending?
    user.present? && user_is_customer_or_stylist?
  end

  # Customers can book available appointments
  def book?
    user.customer? && record.pending?
  end

  # Same as book - reviewing is part of the booking flow
  def review?
    book?
  end

  def confirmation?
    user.present? && record.customer_id == user.id
  end

  def booked?
    user_is_customer_or_stylist?
  end

  # Only customers can create appointment requests (future feature)
  def create?
    user.customer?
  end

  # Only the stylist can accept their pending appointments
  def accept?
    user.stylist? && record.stylist_id == user.id && record.pending?
  end

  # Only the stylist or customer can complete appointments
  # Stylists can complete anytime, customers must wait until after appointment time
  def complete?
    return false unless record.booked?

    if user.stylist? && record.stylist_id == user.id
      true
    elsif user.customer? && record.customer_id == user.id
      record.time < Time.current
    else
      false
    end
  end

  # Stylists can cancel anytime, customers can only cancel their own bookings
  def destroy?
    if user.stylist? && record.stylist_id == user.id
      true
    elsif user.customer? && record.customer_id == user.id
      true
    else
      false
    end
  end

  # Alias for destroy
  def cancel?
    destroy?
  end

  def my_appointments?
    true # Any user can view their own appointments
  end

  private

  def user_is_customer_or_stylist?
    return false unless user
    (record.customer_id == user.id) || (record.stylist_id == user.id)
  end
end
