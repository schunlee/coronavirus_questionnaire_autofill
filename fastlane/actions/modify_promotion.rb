# encoding: UTF-8
require 'spaceship'
require 'faraday'
require 'json'
require 'terminal-table'


module Fastlane
  module Actions
    module SharedValues
      MODIFY_PROMOTION_CUSTOM_VALUE = :MODIFY_PROMOTION_CUSTOM_VALUE
    end

    class ModifyPromotionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        product_id = params[:product_id]
        promotion_flag = params[:promotion_flag]
        order_num = params[:order_num]

        UI.message("find parameter >> product_id:#{product_id} 🌸")
        UI.message("find parameter >> promotion_flag:#{promotion_flag} 🌸")
        UI.message("find parameter >> order_num:#{order_num} 🌸")
        
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

        target_reference_name = ''
        app.in_app_purchases.all.each do | purch |
            if purch.product_id == product_id
                target_reference_name = purch.reference_name
            end
        end
        if target_reference_name == ''
            raise Exception.new "\u001b[31mCannot find such product_id 👿"
        end
        UI.message "0️⃣ List App Store Promotions"
        promotions_list = list_promotions(cookies, app_id)
        UI.message "1️⃣ Update target promotion"
        promotion_data = wrap_update_promotions(target_reference_name, promotions_list, promotion_flag, order_num)
        puts update_promotions(cookies, app_id, promotion_data.to_json)
        UI.message "👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏"
      end
      
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end
      
      def self.wrap_update_promotions(reference_name, promotions_list, promotion_flag, order_num)
          target_obj = nil
          promotions_list.each do |item|
              if item["referenceName"] == reference_name
                  item.update({:isActive => promotion_flag})
                  target_obj = item
              end
          end
          promotions_list.delete(target_obj)
          promotions_list.insert(order_num-1, target_obj)
          promotions_list.each_index do |index|
              promotions_list[index].update({:sortPosition => index})
          end
          return promotions_list
      end
      
      def self.update_promotions(cookies, app_id, promotion_data)
          resp = Faraday.post("https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/#{app_id}/iaps/merch") do |req|
             req.headers = {"Accept" => "application/json, text/plain, */*",
                            "Content-Type" => "application/json;charset=UTF-8",
                            "X-Csrf-Itc": "itc",
                            "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
                            "Cookie" => cookies ,
                            }
             req.body = promotion_data
          end
          resp_dict = JSON.parse resp.body
          return resp_dict
      end
      
      def self.list_promotions(cookies, app_id)
         resp = Faraday.get("https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/#{app_id}/iaps/merch") do |req|
             req.headers['Accept'] = 'application/json, text/plain, */*'
             req.headers['Cookie'] = cookies
             req.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36"
         end
         resp_json = JSON.parse resp.body
         table = Terminal::Table.new do |t|
              t << ["App Store Promotions"]
              t << :separator
              resp_json["data"].each do |item|
                  #puts item
                  t.add_row [item.to_s]
              end
         end
         puts table
         return resp_json["data"]
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
          FastlaneCore::ConfigItem.new(key: :promotion_flag,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_API_TOKEN", # The name of the environment variable
                                       description: "API Token for AutoRenewableSubscriptionAction", # a short description of this parameter,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :order_num,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       type: Integer),
          FastlaneCore::ConfigItem.new(key: :product_id,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['MODIFY_PROMOTION_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        [""]
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
