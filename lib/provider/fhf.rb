require "wombat"
require "provider/base"

module Provider
  class FHF < Base

    MONTH_MAPPING = {
      "janvier"   => "01",
      "février"   => "02",
      "mars"      => "03",
      "avril"     => "04",
      "mai"       => "05",
      "juin"      => "06",
      "juillet"   => "07",
      "août"      => "08",
      "septembre" => "09",
      "octobre"   => "10",
      "novembre"  => "11",
      "décembre"  => "12",
    }.freeze

    def self.parse_french_date(date_str)
      date_part = date_str.split(" - ").first
      day, month_str, year = date_part.split(" ")
      month_number = MONTH_MAPPING[month_str]
      Date.parse("#{day}/#{month_number}/#{year}")
    end

    protected

    def offers_hashes
      offers_index.map do |offer|
        puts "Loading offer #{offer["url"]}"
        random_wait
        details = Wombat.crawl do
          base_url BASE_URL
          path offer["url"][BASE_URL.size .. -1]

          type %{xpath=//div[@class="detail_offre"]/div[@class="informations"][2]/text()[2]} do |t|
            t.split(";").first.strip
          end

          zipcode %{xpath=//div[@class="description_geographique_offre"]//p[@class="address"]/text()[3]} do |z|
            z.scan(/\d/).first(5).join
          end
        end
        offer.merge(details)
      end
    end

    private

    BASE_URL = "http://emploi.fhf.fr".freeze
    JOBLIST_PATH = "/offres-emploi.php?metiers[]=112&type=SOI&page=%s"
    JOB_PATH_TEMPLATE = "/offre-emploi.php?id=%s"

    def offers_index(page: 1, offers: [])
      result = crawl_index_page(page)
      offers += result["offers"]
      if result["page_count"] > page
        offers_index(page: page + 1, offers: offers)
      else
        offers
      end
    end

    def crawl_index_page(page)
      Wombat.crawl do
        base_url BASE_URL
        path JOBLIST_PATH % [ page ]

        page_count "css=a.num_page", :list do |list|
          list.map(&:to_i).max
        end

        offers "css=#nos_dernieres_offres li", :iterator do
          created_at("css=span.date") { |d| FHF.parse_french_date(d) }
          name(%{xpath=span[@class="hopital"]/text()[1]})
          url(%{xpath=a/@href}) { |path| [BASE_URL, path].join("/") }
          city("css=span.hopital span") { |c| c.gsub(/[()]/, "") }
        end
      end
    end

    def random_wait
      delay = 2 + (rand(3000) / 1000)
      puts "Wait #{delay} seconds to seems a real person"
      sleep delay
    end
  end
end
