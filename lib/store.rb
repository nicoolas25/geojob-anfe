require "pstore"

# This class persists the offers in a way that you don't need to
# use the provider everytime. This specific store work with the
# PStore library. Also this store cache only the data for a day.
# To use a store you have to provide the Provider and the Locator
# objects.
#
# The store is THE way to get the offers because it ensure that
# they do have a latitude and longitude.
class Store
  def initialize(options)
    @provider = options[:provider] || options.fetch("provider")
    @locator = options[:locator] || options.fetch("locator")
  end

  def offers
    saved_offers || retrieve_offers
  end

  def store(offers)
    pstore.transaction { pstore[:offers] = offers.map(&:to_hash) }
  end

  private

  def saved_offers
    hashes = pstore.transaction { pstore[:offers] }
    hashes && hashes.map { |hash| Offer.new(hash) }
  end

  def retrieve_offers
    @provider.fetch_offers.map do |offer|
      offer.tap { offer.set_coordinates(@locator) }
    end.tap { |offers| store(offers) }
  end

  def pstore
    @pstore ||= PStore.new(filename)
  end

  def filename
    date_prefix = Date.today.strftime("%Y%m%d")
    provider_name = @provider.class.name.split('::').last.downcase
    "#{date_prefix}-#{provider_name}-jobs.pstore"
  end
end
