module Fastlane
  module Actions
    module SharedValues
      UPDATE_COUNTRY_AVAILABILITY_CUSTOM_VALUE = :UPDATE_COUNTRY_AVAILABILITY_CUSTOM_VALUE
    end

    class UpdateCountryAvailabilityAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        exclude_cn = params[:exclude_cn]
        UI.message("find parameter >> exclude_cn:#{exclude_cn} 🌸")

        countries = ["NP","VE","RU","LV","CM","BJ","BE","CD","ZW","CY","AL","UG","SI","MA","DZ","DE","BF","GW","NA",
                     "MU","AR","BY","CI","TO","ML","ES","JM","AU","RW","PE","HU","DK","CL","ID","MO","EG","CZ","SG",
                     "FR","BA","GR","NL","MZ","YE","GA","KZ","IQ","SK","DM","LT","SB","CO","NR","BW","FJ","CG","PK",
                     "HK","BO","GE","GM","EC","AI","SE","LC","PY","BM","TC","LK","AE","TT","SR","MR","PL","MM","TM",
                     "BS","NE","HN","RO","AT","PW","GY","BT","MT","VN","TZ","NG","GH","CA","GD","NI","ZM","MD","BH",
                     "AO","BR","MV","SV","BN","AZ","VU","KW","OM","MX","AG","MS","VG","KG","TW","TJ","ME","SZ","GT",
                     "PG","RS","ST","AM","BZ","ZA","PH","PA","DO","NZ","EE","TR","CH","FI","GB","XK","IE","MG","KY",
                     "CN","UA","FM","VC","AF","SA","KH","TN","IS","SN","MW","LR","SL","MN","BG","LY","JP","LA","JO",
                     "PT","US","QA","HR","UZ","LB","UY","CR","IN","MK","TD","MY","LU","IL","KE","NO","BB","IT","TH",
                     "KN","KR","SC","CV"]
        if exclude_cn == "true"
            countries -= ["CN"]
        end
        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::Application.find(ENV['APP_IDENTIFIER'])
        availability = Spaceship::Tunes::Availability.from_territories(countries)
        app.update_availability!(availability)
        UI.message "💯 💯 💯"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update country or region availability on app store connect"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Update country or region availability on app store connect"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :exclude_cn,
                                       env_name: "EXCLUDE_CN", # The name of the environment variable
                                       description: "Exclude CN Flag for UpdateBillingGracePeriodAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No opt_in for UpdateBillingGracePeriodAction given, pass using `exclude_in: 'exclude_in'`") unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['UPDATE_COUNTRY_AVAILABILITY_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
