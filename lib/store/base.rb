module Store
  # This class persists the offers in a way that you don't need to
  # use the provider everytime. Also a store cache only the data for
  # a day. To use a store you have to provide the Provider and the
  # Locator objects.
  #
  # The store is THE way to get the offers because it ensure that
  # they do have a latitude and longitude.
  class Base
    def initialize(options)
      @provider = options[:provider] || options.fetch("provider")
      @locator = options[:locator] || options.fetch("locator")
      post_initialize(options)
    end

    def offers
      saved_offers || retrieve_offers
    end

    def store(offers)
      raise "The #{self.class.name} should implement the #store method"
    end

    protected

    def provider_id
      @provider.provider_id
    end

    def saved_offers
      raise "The #{self.class.name} should implement the #store method"
    end

    def post_initialize(options)
      # Subclass this to handle custom initialization options
    end

    def retrieve_offers
      @provider.fetch_offers.map do |offer|
        offer.tap { offer.set_coordinates(@locator) }
      end.tap { |offers| store(offers) }
    end
  end
end
