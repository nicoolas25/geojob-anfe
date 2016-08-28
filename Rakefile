$LOAD_PATH.unshift("./lib")

require "provider/anfe"
require "zipcode_locator/csv"
require "store"

desc "Fetch the offers from every available provider and store them"
task :fetch_offers do
  Store.new({
    provider: Provider::ANFE.new,
    locator: ZipcodeLocator::CSV.new,
  }).offers
end

