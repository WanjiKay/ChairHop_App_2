module AddressHelper
  def formatted_address(user)
    if user.street_address.present?
      parts = [
        user.street_address,
        [user.city, user.state, user.zip_code].compact_blank.join(', ')
      ].compact_blank
      safe_join(parts, tag.br)
    else
      "Address not provided"
    end
  end

  def short_address(user)
    if user.city.present? && user.state.present?
      "#{user.city}, #{user.state}"
    elsif user.respond_to?(:location_cities) && user.location_cities.present?
      user.location_cities
    else
      "Location not set"
    end
  end
end
