module Fastlane
  module Actions
    module SharedValues
      REMOVE_SUBSCRIPTION_CUSTOM_VALUE = :REMOVE_SUBSCRIPTION_CUSTOM_VALUE
    end

    class RemoveSubscriptionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        UI.message "🍭 \u001b[36;1mRemove IAP"
        product_id = params[:product_id]
        UI.message("find parameter >> product_id:#{product_id} 🌸")

        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
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
        
        iaps = app.in_app_purchases.all

        for i in 0..iaps.size - 1
            if iaps.at(i).product_id == product_id
                # puts iaps.at(i).delete!
                purch_id = iaps.at(i).edit.purchase_id
                app_id = app.apple_id
                UI.message("find parameter >> purch_id:#{purch_id} 🌸")
                UI.message("find parameter >> app_id:#{app_id} 🌸")
                client = Faraday.new(url: "https://appstoreconnect.apple.com") do |conn|
                    conn.headers['Cookie'] = cookies
                    conn.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36"
                    conn.adapter :net_http
                end

                resp = client.delete("/WebObjects/iTunesConnect.woa/ra/apps/#{app_id}/iaps/#{purch_id}")
                puts resp.body
            end
        
        end
        raise Exception.new "\n\u001b[31mCannot find IAP(product_id) ==> #{product_id}👿"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options 
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :product_id,
                                       env_name: "PRODUCT_ID", # The name of the environment variable
                                       description: "API Token for RemoveSubscriptionAction")
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['REMOVE_SUBSCRIPTION_CUSTOM_VALUE', 'A description of what this value contains']
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
