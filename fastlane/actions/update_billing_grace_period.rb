#require 'spaceship'
require 'yaml'
require 'faraday'

module Fastlane
  module Actions
    module SharedValues
      UPDATE_BILLING_GRACE_PERIOD_CUSTOM_VALUE = :UPDATE_BILLING_GRACE_PERIOD_CUSTOM_VALUE
    end

    class UpdateBillingGracePeriodAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        opt_in = params[:opt_in]
        UI.message("find opt_in:#{opt_in} 🌸")

        client = Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::Application.find(ENV['APP_IDENTIFIER'])
        itc_cookie_content = Spaceship::Tunes.client.store_cookie
        cookies = YAML.safe_load(
           itc_cookie_content,
           [HTTP::Cookie, Time], # classes whitelist
           [],                   # symbols whitelist
           true                  # allow YAML aliases
         )

         # We remove all the un-needed cookies
         cookies.select! do |cookie|
           cookie.name.start_with?("myacinfo") || cookie.name == 'dqsid'
         end
        cookies = cookies.join(sep=";",)
        app_id = app.apple_id
        resp = Faraday.patch("https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/#{app_id}/iaps/gracePeriod", {"optIn": opt_in}.to_json,
          {"Content-Type" => "application/vnd.api+json",
           "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
           "Cookie" => cookies ,
          })
        UI.message resp.body
        if not resp.body.downcase.include? "success"
            UI.message "👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽 👎🏽"
            raise Exception.new("error occur >>>" + resp.body)
        end
        UI.message "👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏"

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "An action to open or close Billing Grace Period"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "to open or close Billing Grace Period on In-App Purchases of Apple App Store Connect"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :opt_in,
                                       env_name: "OPT_IN", # The name of the environment variable
                                       description: "Opt_in for UpdateBillingGracePeriodAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No opt_in for UpdateBillingGracePeriodAction given, pass using `opt_in: 'opt_in'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['UPDATE_BILLING_GRACE_PERIOD_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["bill.li"]
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
