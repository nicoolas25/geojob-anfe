require "wombat"
require_relative "../offer"

module Provider
  class ANFE
    BASE_URL = "http://www.anfe.fr".freeze
    JOBLIST_PATH = "/index.php/component/offresemploi/?view=offres"
    JOB_PATH_TEMPLATE = "/component/offresemploi/%s?view=offre"

    def fetch_offers
      offers_hashes.map { |hash| Offer.new(hash) }
    end

    private

    def offers_hashes
      offers_index.map do |offer|
        puts "Loading offer..."
        details = Wombat.crawl do
          base_url BASE_URL
          path JOB_PATH_TEMPLATE % [ offer.fetch("reference") ]

          address %{xpath=//form[@id="offreForm"]//fieldset[2]/li[2]/text()[3]}
          type %{xpath=//form[@id="offreForm"]//fieldset[3]/li[1]/text()[3]}
        end
        details[:url] = (BASE_URL + JOB_PATH_TEMPLATE) % offer.fetch("reference")
        offer.merge(details)
      end
    end

    def offers_index
      Wombat.crawl do
        base_url BASE_URL
        path JOBLIST_PATH

        offers "css=li.oeListe", :iterator do
          reference(%{xpath=a/span[@class="oeLabel80"][2]}) { |r| r.scan(/\d+/).first }
          zipcode(%{xpath=a/span[@class="oeLabel80"][3]}) { |z| z.scan(/\d+/).join }
          created_at(%{xpath=a/span[@class="oeLabel80"][1]}) { |d| Date.parse(d) }
          city("css=span.oeLabelVille")
          name("css=span.oeLabelNom")
        end
      end["offers"]
    end

  end
end
