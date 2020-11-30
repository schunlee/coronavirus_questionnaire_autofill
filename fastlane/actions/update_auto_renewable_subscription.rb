module Fastlane
  module Actions
    module SharedValues
      UPDATE_AUTO_RENEWABLE_SUBSCRIPTION_CUSTOM_VALUE = :UPDATE_AUTO_RENEWABLE_SUBSCRIPTION_CUSTOM_VALUE
    end

    class UpdateAutoRenewableSubscriptionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        UI.message "🍭 \u001b[36;1mUpdate Auto Renewable IAP"

        product_id = params[:product_id]
        reference_name = params[:reference_name]
        review_notes = params[:review_notes]
        iap_version_dict = params[:iap_version_dict]
        review_pic_url = params[:review_pic_url]
        merch_pic_url = params[:merch_pic_url]
        cleared_flag = params[:cleared_flag]
        price_tier = params[:price_tier]
        subscription_duration = params[:subscription_duration]


        UI.message("find parameter >> product_id:#{product_id} 🌸")
        UI.message("find parameter >> reference_name:#{reference_name} 🌸")
        UI.message("find parameter >> review_notes:#{review_notes} 🌸")
        UI.message("find parameter >> review_pic_url:#{review_pic_url} 🌸")
        UI.message("find parameter >> merch_pic_url:#{merch_pic_url} 🌸")
        UI.message("find parameter >> cleared_flag:#{cleared_flag} 🌸")
        UI.message("find parameter >> price_tier:#{price_tier} 🌸")
        UI.message("find parameter >> iap_version_dict:#{iap_version_dict} 🌸")
        UI.message("find parameter >> subscription_duration:#{subscription_duration} 🌸")


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
        app_id = app.apple_id

        iaps = app.in_app_purchases.all

        for i in 0..iaps.size - 1
            if iaps.at(i).product_id == product_id
                e = iaps.at(i).edit
                origin_review_notes = get_promotion_review_notes(cookies, app_id, e.purchase_id)
                puts "origin_review_notes >> #{origin_review_notes} 🌸"
                if subscription_duration != nil
                    if not ["1w", "1m", "2m", "3m", "6m", "1y"].map{|e|e}.include? duration
                        raise Exception.new "\u001b[31mWrong duration for IAP (valid duration values ==> 1w, 1m, 2m, 3m, 6m, 1y) 👿"
                    end
                    e.subscription_duration = subscription_duration
                end
                if iap_version_dict != {} and iap_version_dict != nil
                    e.version = iap_version_dict
                end
                if cleared_flag != nil and cleared_flag != ""
                    e.cleared_for_sale = cleared_flag
                end
                if review_pic_url != nil and review_pic_url != ""
                    open("review.png", "wb") do |file|
                        file << open(review_pic_url).read
                    end
                    e.review_screenshot = "review.png"
                end
                if merch_pic_url != nil and merch_pic_url != ""
                    open("merch.png", "wb") do |file|
                        file << open(merch_pic_url).read
                    end
                    e.merch_screenshot = "merch.png"
                end
                if review_notes != ""
                        puts "review_notes"
                        e.review_notes = review_notes
                    else
                        e.review_notes = origin_review_notes # fix bugs on Spaceship https://github.com/fastlane/fastlane/discussions/17671
                if price_tier != nil and price_tier != ""
                    e.subscription_price_target["tier"] = price_tier
                end
                puts e.save!
                UI.message "👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏"
                return
                end
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
                    FastlaneCore::ConfigItem.new(key: :reference_name,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :product_id,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :review_pic_url,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :merch_pic_url,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :review_notes,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :price_tier,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :cleared_flag,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :subscription_duration,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: nil,
                                                 description: "Create a development certificate instead of a distribution one"),
                    FastlaneCore::ConfigItem.new(key: :iap_version_dict,
                                                 env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                                 default_value: {},
                                                 description: "Create a development certificate instead of a distribution one",
                                                 type: Hash)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['UPDATE_AUTO_RENEWABLE_SUBSCRIPTION_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["bill.li"]
      end
      
      def self.get_promotion_review_notes(cookies, app_id, iap_id)
         resp = Faraday.get("https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/#{app_id}/iaps/#{iap_id}") do |req|
             req.headers['Accept'] = 'application/json, text/plain, */*'
             req.headers['Cookie'] = cookies
             req.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36"
         end
         resp_json = JSON.parse resp.body
         return resp_json["data"]["versions"][0]["reviewNotes"]["value"]
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
