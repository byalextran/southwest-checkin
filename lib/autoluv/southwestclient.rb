require "rest-client"
require "securerandom"
require "json"
require "tzinfo"
require "shellwords"

module Autoluv
  class SouthwestClient
    @confirmation_number = @first_name = @last_name = @options = nil

    # minimum required headers for all API calls
    DEFAULT_HEADERS = {
      "Content-Type": "application/json",
      "X-API-Key": "l7xx0a43088fe6254712b10787646d1b298e",
      "X-Channel-ID": "MWEB", # required now for viewing a reservation
    }

    CHECK_IN_URL = "https://mobile.southwest.com/api/mobile-air-operations/v1/mobile-air-operations/page/check-in"
    RESERVATION_URL = "https://mobile.southwest.com/api/mobile-air-booking/v1/mobile-air-booking/page/view-reservation"

    TIME_ZONES_PATH = File.expand_path("../../data/airport_time_zones.json", __dir__)

    def self.schedule(confirmation_number, first_name, last_name, to = nil, bcc = nil)
      flights = self.departing_flights(confirmation_number, first_name, last_name)

      flights.each_with_index do |flight, x|
        check_in_time = self.check_in_time(flight)

        puts "Scheduling flight departing #{flight[:airport_code]} at #{flight[:departure_time]} on #{flight[:departure_date]}."

        command = "echo 'autoluv checkin #{confirmation_number} #{Shellwords.shellescape(first_name)} #{Shellwords.shellescape(last_name)} #{to} #{bcc}' | at #{check_in_time.strftime('%I:%M %p %m/%d/%y')}"
        `#{command}`

        puts unless x == flights.size - 1
      end
    end

    def self.check_in(confirmation_number, first_name, last_name, to = nil, bcc = nil)
      check_in = attempt = nil

      # try checking in multiple times in case the our server time is out of sync with Southwest's.
      num_attempts = 10

      start_time = Time.now

      num_attempts.times do |x|
        begin
          attempt = x + 1
          post_data = self.check_in_post_data(confirmation_number, first_name, last_name)
          check_in = RestClient.post("#{CHECK_IN_URL}", post_data.to_json, self.headers)
          break
        rescue RestClient::ExceptionWithResponse => ewr
          sleep(1)
          next unless x == num_attempts - 1

          raise
        end
      end

      end_time = Time.now
      boarding_positions = ""

      check_in_json = JSON.parse(check_in)
      flights = check_in_json["checkInConfirmationPage"]["flights"]

      # make the output more user friendly
      flights.each_with_index do |flight, x|
        boarding_positions << flight["originAirportCode"] << "\n"

        flight["passengers"].each do |passenger|
          boarding_positions << "- #{passenger["name"]} (#{passenger["boardingGroup"]}#{passenger["boardingPosition"]})" << "\n"
        end

        boarding_positions << "\n" unless x == flights.size - 1
      end

      metadata = {
        end_time: end_time.strftime("%I:%M.%L"),
        elapsed_time: (end_time - start_time).round(2),
        attempts: attempt,
      }

      Autoluv::notify_user(true, confirmation_number, first_name, last_name, { to: to, bcc: bcc, boarding_positions: boarding_positions, metadata: metadata })
    end

    private
    def self.headers
      # required now for all API calls
      DEFAULT_HEADERS.merge({ "X-User-Experience-ID": SecureRandom.uuid })
    end

    def self.departing_flights(confirmation_number, first_name, last_name)
      reservation = RestClient.get("#{RESERVATION_URL}/#{confirmation_number}?first-name=#{first_name}&last-name=#{last_name}", self.headers)
      reservation_json = JSON.parse(reservation)

      airport_time_zones = JSON.parse(File.read(TIME_ZONES_PATH))

      departing_flights = reservation_json["viewReservationViewPage"]["bounds"].map do |bound|
        airport_code = bound["departureAirport"]["code"]

        {
          airport_code: airport_code,
          departure_date: bound["departureDate"],
          departure_time: bound["departureTime"],
          time_zone: airport_time_zones[airport_code],
        }
      end
    end

    def self.check_in_post_data(confirmation_number, first_name, last_name)
      check_in = RestClient.get("#{CHECK_IN_URL}/#{confirmation_number}?first-name=#{first_name}&last-name=#{last_name}", self.headers)
      check_in_json = JSON.parse(check_in)
      check_in_json["checkInViewReservationPage"]["_links"]["checkIn"]["body"]
    end

    def self.check_in_time(flight)
      tz_abbreviation = TZInfo::Timezone.get(flight[:time_zone]).current_period.offset.abbreviation.to_s

      # 2020-09-21 13:15 CDT
      departure_time = Time.parse("#{flight[:departure_date]} #{flight[:departure_time]} #{tz_abbreviation}")

      # subtract a day (in seconds) to know when we can check in
      check_in_time = departure_time - (24 * 60 * 60)

      # compensate for our server time zone
      check_in_time -= (departure_time.utc_offset - Time.now.utc_offset)
    end
  end
end
