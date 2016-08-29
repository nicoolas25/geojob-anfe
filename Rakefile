$LOAD_PATH.unshift("./lib")

require "provider/anfe"
require "provider/fhf"
require "zipcode_locator/csv"
require "store"

PROVIDERS = [ Provider::ANFE, Provider::FHF ]

desc "Fetch the offers from every available provider and store them"
task :fetch_offers do
  PROVIDERS.each do |provider_class|
    Store.new({
      provider: provider_class.new,
      locator: ZipcodeLocator::CSV.new,
    }).offers
  end
end

task :console do
  require "pry"
  ARGV.clear
  Pry.start
end

