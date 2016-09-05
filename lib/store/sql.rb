# In development mode, don't forget the environment variable:
#
#   DATABASE_URL=postgres://postgres:mysecretpassword@127.0.0.1:5432/geojob

require "sequel"
require "json"
require "store/base"

module Store
  # This specific store work with SQL databases.
  class SQL < Base

    def store(offers)
      DB.transaction { offers.each { |offer| store_offer(offer) } }
    end

    protected

    def saved_offers
      rows = DB[:jobs].where(date: Date.today, provider_id: provider_id).all
      rows.any? && rows.map { |row| parse_offer(row) }
    end

    private

    DB = Sequel.connect(ENV["DATABASE_URL"]).tap do |db|
      db.create_table?(:jobs) do
        String :provider_id, size: 50
        Date :date
        String :offer, text: true
      end
    end

    def store_offer(offer)
      DB[:jobs].insert({
        provider_id: provider_id,
        date: Date.today,
        offer: JSON.generate(offer.to_hash)
      })
    end

    def parse_offer(row)
      hash_offer = JSON.parse(row[:offer])
      Offer.new(hash_offer)
    end
  end
end
