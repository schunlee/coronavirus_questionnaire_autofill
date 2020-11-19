require 'spaceship'
require 'yaml'
require 'faraday'

module Fastlane
  module Actions
    module SharedValues
      UPDATE_APP_STORE_SERVER_NOTIFICATIONS_CUSTOM_VALUE = :UPDATE_APP_STORE_SERVER_NOTIFICATIONS_CUSTOM_VALUE
    end

    class UpdateAppStoreServerNotificationsAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        server_url = params[:server_url]
        UI.message("find server url:#{server_url} 🌸")
        
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
        UI.message cookies
        app_id = app.apple_id
        resp = Faraday.patch("https://appstoreconnect.apple.com/iris/v1/apps/#{app_id}",
        {"data" => {"type" => "apps","id" => app_id, "attributes" => {"subscriptionStatusUrl" => server_url}}}.to_json,
          {"Content-Type" => "application/vnd.api+json",
           "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
           "Cookie" => cookies ,
          })
        UI.message resp.body
        UI.message "👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏"

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "An action to change the URL for App Store Server Notifications"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "to change the URL for App Store Server Notifications on App Information of Apple Store Connect"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :server_url,
                                       env_name: "NOTIFICATION_SERVER_URL", # The name of the environment variable
                                       description: "target server notification url", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No server url for UpdateAppStoreServerNotificationsAction given, pass using `server_url: 'server_url'`") unless (value and not value.empty?)
                                       end),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['UPDATE_APP_STORE_SERVER_NOTIFICATIONS_CUSTOM_VALUE', 'A description of what this value contains']
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
