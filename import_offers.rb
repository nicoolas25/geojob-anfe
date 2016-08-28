require 'pstore'
require 'wombat'

ANFE_URL = 'http://www.anfe.fr'
JOBLIST_PATH = '/index.php/component/offresemploi/?view=offres'
JOB_PATH = '/component/offresemploi/%s?view=offre'

date_prefix = Date.today.strftime("%Y%m%d")
store = PStore.new("#{date_prefix}-anfe-jobs.pstore")
offers_by_reference = store.transaction { store[:offers_by_reference] }

if offers_by_reference.nil?
  puts "Reading job list..."
  index = Wombat.crawl do
    base_url ANFE_URL
    path JOBLIST_PATH

    offers 'css=li.oeListe', :iterator do
      reference('xpath=a/span[@class="oeLabel80"][2]') { |r| r.scan(/\d+/).first }
      zipcode('xpath=a/span[@class="oeLabel80"][3]') { |z| z.scan(/\d+/).join }
      city('css=span.oeLabelVille')
      name('css=span.oeLabelNom')
    end
  end

  offers_by_reference = {}

  index["offers"].each do |offer|
    reference = offer.fetch("reference")

    puts "Reading job ##{reference}..."
    details = Wombat.crawl do
      base_url ANFE_URL
      path JOB_PATH % [ reference ]

      address 'xpath=//form[@id="offreForm"]//fieldset[2]/li[2]/text()[3]'
      type 'xpath=//form[@id="offreForm"]//fieldset[3]/li[1]/text()[3]'
    end

    offers_by_reference[reference] = offer.merge(details)
  end

  store.transaction do
    store[:offers_by_reference] = offers_by_reference
  end
end
