$LOAD_PATH.unshift("./lib")

require "json"
require "sinatra/base"

require "provider/anfe"
require "provider/fhf"
require "zipcode_locator/csv"
require "store/sql"

PROVIDERS = [ Provider::ANFE, Provider::FHF ]

class Geojob < Sinatra::Base
  get '/' do
    @offers = decorated_offers
    @api_key = ENV["GOOGLE_MAP_API_KEY"]
    erb :index
  end

  private

  def decorated_offers
    offers_by_coords.each_with_object({}) do |(coords, offers), result|
      result[coords] = offers.sort.map { |offer| decorate_offer(offer) }
    end
  end

  def offers_by_coords
    offers_array.each_with_object({}) do |offer, hash|
      (hash["#{offer.lat}#{offer.lng}"] ||= []) << offer
    end
  end

  def offers_array
    PROVIDERS.map do |provider_class|
      Store::SQL.new({
        provider: provider_class.new,
        locator: ZipcodeLocator::CSV.new,
      }).offers
    end.flatten(1)
  end

  def decorate_offer(offer)
    offer_hash = offer.to_hash.tap do |hash|
      if offer.created_at.kind_of?(Date)
        hash[:age] = (Date.today - offer.created_at).to_i
        hash[:provider] = offer.provider
      end
    end
  end
end
