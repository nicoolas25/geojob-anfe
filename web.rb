require "pstore"
require "json"
require "sinatra/base"

date_prefix = Date.today.strftime("%Y%m%d")
store = PStore.new("#{date_prefix}-anfe-jobs.pstore")
OFFERS_BY_COORDS = store.transaction { store[:offers_by_coords] }
fail "You should have a database for the day before trying to serve the page" unless OFFERS_BY_COORDS

class Geojob < Sinatra::Base
  get '/' do
    @api_key = ENV["GOOGLE_MAP_API_KEY"]
    erb :index
  end
end
