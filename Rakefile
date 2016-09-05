$LOAD_PATH.unshift("./lib")

require "provider/anfe"
require "provider/fhf"
require "zipcode_locator/csv"

PROVIDERS = [ Provider::ANFE, Provider::FHF ]

namespace :pstore do
  desc "Fetch the offers from every available provider and store them in a file"
  task :fetch_offers do
    require "store/pstore"

    PROVIDERS.each do |provider_class|
      Store::PStore.new({
        provider: provider_class.new,
        locator: ZipcodeLocator::CSV.new,
      }).offers
    end
  end
end

namespace :db do
  desc "Fetch the offers from every available provider and store them in a database"
  task :fetch_offers do
    require "store/sql"

    PROVIDERS.each do |provider_class|
      Store::SQL.new({
        provider: provider_class.new,
        locator: ZipcodeLocator::CSV.new,
      }).offers
    end
  end
end

task :console do
  require "pry"
  ARGV.clear
  Pry.start
end

