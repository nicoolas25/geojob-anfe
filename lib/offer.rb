# This class represents a job offer.
class Offer
  include Comparable

  attr_reader :name, :city, :zipcode, :type, :created_at, :url, :lat, :lng

  attr_accessor :provider

  def initialize(hash)
    ATTRIBUTES.each do |attr|
      instance_variable_set("@#{attr}", hash[attr] || hash[attr.to_s])
    end
  end

  def <=>(other)
    self.created_at <=> other.created_at
  end

  def set_coordinates(zipcode_locator)
    @lat, @lng = zipcode_locator.coords(zipcode)
  end

  def to_hash
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      hash[attr] = self.__send__(attr)
    end
  end

  private

  ATTRIBUTES = %i(name city zipcode type created_at url lat lng).freeze
end
