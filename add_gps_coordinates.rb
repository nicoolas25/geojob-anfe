require "pstore"
require "csv"

date_prefix = Date.today.strftime("%Y%m%d")
store = PStore.new("#{date_prefix}-anfe-jobs.pstore")
offers_by_reference = store.transaction { store[:offers_by_reference] }
fail "Import today's offers prior to run this script." unless offers_by_reference

CITY_PATH = "./communes.csv"

coordinates = {}
CSV.foreach(CITY_PATH) do |row|
  zipcodes = row[1].split("-")
  lat = row[2].to_f
  long = row[3].to_f
  zipcodes.each do |zipcode|
    coordinates[zipcode] = [lat, long]
  end
end

def find_coordinates(coordinates, zipcode, offer)
  return coordinates[zipcode] if coordinates.has_key?(zipcode)

  # Marseille 13000 -> 13001
  if zipcode.size == 5 && zipcode[4] == "0"
    (new_zipcode = zipcode.dup)[4] = "1"
    return coordinates[new_zipcode] if coordinates.has_key?(new_zipcode)
  end

  # Bicêtre 94275 -> 94270
  if zipcode.size == 5 && zipcode[4] != "0"
    (new_zipcode = zipcode.dup)[4] = "0"
    return coordinates[new_zipcode] if coordinates.has_key?(new_zipcode)
  end

  if zipcode.size == 5 && new_zipcode[3..4] != "00"
    (new_zipcode = zipcode.dup)[3..4] = "00"
    return coordinates[new_zipcode] if coordinates.has_key?(new_zipcode)
  end

  if zipcode.size == 5 && new_zipcode[2..4] != "000"
    (new_zipcode = zipcode.dup)[2..4] = "000"
    return coordinates[new_zipcode] if coordinates.has_key?(new_zipcode)
  end

  # Default coordinates in the water near Nantes
  [ 46.8937365, -2.90 ]
end

offers_by_coords = {}
offers_by_reference.each do |reference, offer|
  zipcode = offer["zipcode"]
  coords = find_coordinates(coordinates, zipcode, offer)
  coords_str = coords.join("-")
  (offers_by_coords[coords_str] ||= []) << offer
  offer["coords"] = coords
end

store.transaction do
  store[:offers_by_reference] = offers_by_reference
  store[:offers_by_coords] = offers_by_coords
end
