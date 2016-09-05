require "pstore"
require "store/base"

module Store
  # This specific store work with the ::PStore library.
  class PStore < Base

    def store(offers)
      pstore.transaction { pstore[:offers] = offers.map(&:to_hash) }
    end

    protected

    def saved_offers
      hashes = pstore.transaction { pstore[:offers] }
      hashes && hashes.map do |hash|
        Offer.new(hash).tap do |offer|
          offer.provider = @provider.class.provider_id
        end
      end
    end

    def pstore
      @pstore ||= ::PStore.new(filename)
    end

    def filename
      date_prefix = Date.today.strftime("%Y%m%d")
      provider_name = @provider.class.provider_id
      "#{date_prefix}-#{provider_name}-jobs.pstore"
    end
  end
end
