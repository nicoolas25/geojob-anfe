require "wombat"
require "provider/base"

module Provider
  class ANFE < Base

    protected

    def offers_hashes
      offers_index.map do |offer|
        puts "Loading offer..."
        reference = offer.fetch("reference")
        details = Wombat.crawl do
          base_url BASE_URL
          path JOB_PATH_TEMPLATE % [ reference ]

          type %{xpath=//form[@id="offreForm"]//fieldset[3]/li[1]/text()[3]}
        end
        details.delete("reference")
        details["url"] = (BASE_URL + JOB_PATH_TEMPLATE) % [ reference ]
        offer.merge(details)
      end
    end

    private

    BASE_URL = "http://www.anfe.fr".freeze
    JOBLIST_PATH = "/index.php/component/offresemploi/?view=offres"
    JOB_PATH_TEMPLATE = "/component/offresemploi/%s?view=offre"

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
