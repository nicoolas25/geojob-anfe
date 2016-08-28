require "csv"

# This class use a CSV to map zipcodes to GPS coordinates.
# The CSV is expected to have the following format:
#   - No headers
#   - Separated by commas
#   - Columns: Name of the city, Zipcode, Latitude, Longitude
#   - If a city have multiple zipcode, they are separated by '-'
#   - Zipcodes are String objects
module ZipcodeLocator
  class CSV
    def initialize(filename: "communes.csv")
      @filename = filename
    end

    def coords(zipcode)
      transformation_strategies.each do |strategy|
        new_zipcode = strategy.call(zipcode.dup)
        next unless new_zipcode
        coords = strict_coords(new_zipcode)
        return coords if coords
      end
      DEFAULT_COORDINATES
    end

    private

    DEFAULT_COORDINATES = [46.90, -2.90].freeze

    def strict_coords(zipcode)
      mapping.fetch(zipcode, nil)
    end

    def transformation_strategies
      [
        # Original zipcode
        Proc.new { |zipcode| zipcode },
        # Paris & others (75000 -> 75001)
        Proc.new { |zipcode| zipcode.end_with?("000") && zipcode.gsub(/000$/, "001") },
        # Cedex areas, try to fallback somewhere close...
        Proc.new { |zipcode| zipcode.gsub(/\d$/, "0") },
        Proc.new { |zipcode| zipcode.gsub(/\d\d$/, "00") },
        Proc.new { |zipcode| zipcode.gsub(/\d\d\d$/, "000") },
      ]
    end

    def mapping
      @mapping ||= {}.tap do |mapping|
        ::CSV.foreach(@filename) do |row|
          lat = row[2].to_f
          long = row[3].to_f
          zipcodes = row[1].split("-")
          zipcodes.each do |zipcode|
            mapping[zipcode] = [lat, long]
          end
        end
      end
    end
  end
end
