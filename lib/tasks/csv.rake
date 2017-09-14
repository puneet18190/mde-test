namespace :csv do

  # XXX it must be customized
  desc "Generate a CSV for seeding with the locations starting from an hash"
  task :generate_locations => :environment do
    require 'yaml'
    require 'csv'

    h = YAML.load File.read '/path/to/source.yml'

    i = 0
    si = 0

    csv_string = CSV.generate do |csv|

      csv << %w( id name sti_type ancestry )

      h.each do |province, hh|
        i += 1
        pi = i
        csv << [i, province, 'Province', nil]

        hh.each do |city, counties|
          i += 1
          ppi = i
          csv << [i, city, 'City', "#{pi}"]

          counties.split.each do |county|
            i += 1
            pppi = i
            csv << [i, county, 'County', "#{pi}/#{ppi}"]

            2.times do
              i += 1
              si += 1
              csv << [i, "School #{si}", 'School', "#{pi}/#{ppi}/#{pppi}"]
            end
          end
        end
      end

    end

    File.write Rails.root.join('db/seeds/environments/production/csv/locations.csv'), csv_string
  end

end