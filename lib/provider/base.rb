require "offer"

module Provider
  # This class is the base for other providers integration.
  # By subclassing it, you should implement the `offer_hashes`
  # protected method.
  #
  # In exchange this Base class will keep the Offer's dependency
  # in one place and provide the `fetch_offers` public method.
  class Base
    def fetch_offers
      offers_hashes.map { |hash| Offer.new(hash) }
    end

    protected

    # This method should return a Array<Hash> with the following Symbol
    # or String keys:
    #   - name
    #   - city
    #   - zipcode
    #   - type
    #   - created_at
    #   - url
    # The associated values will be used to build Offer objects.
    def offers_hashes
      fail NotImplementedError
    end
  end
end
