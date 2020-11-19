require 'spaceship'
require 'open-uri'

module Fastlane
  module Actions
    module SharedValues
      NORMAL_SUBSCRIPTION_CUSTOM_VALUE = :NORMAL_SUBSCRIPTION_CUSTOM_VALUE
    end

    class NormalSubscriptionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        product_id = params[:product_id]
        reference_name = params[:reference_name]
        review_notes = params[:review_notes]
        iap_version_dict = params[:iap_version_dict]
        review_pic_url = params[:review_pic_url]
        merch_pic_url = params[:merch_pic_url]
        cleared_flag = params[:cleared_flag]
        price_tier = params[:price_tier]
        subscription_type = params[:subscription_type]
        
        if cleared_flag == true
            cleared_flag = true
        else
            cleared_flag = false
        end
        
        UI.message("find product_id:#{product_id} 🌸")
        UI.message("find reference_name:#{reference_name} 🌸")
        UI.message("find review_notes:#{review_notes} 🌸")
        UI.message("find subscription_type:#{subscription_type} 🌸")
        UI.message("find price_tier:#{price_tier} 🌸")
        UI.message("find cleared_flag:#{cleared_flag} 🌸")
        UI.message("find review_pic_url:#{review_pic_url} 🌸")
        UI.message("find merch_pic_url:#{merch_pic_url} 🌸")
        UI.message("find iap_version_dict:#{iap_version_dict} 🌸")


        open('review.png', 'wb') do |file|
          file << open(review_pic_url).read
        end

        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::Application.find(ENV['APP_IDENTIFIER'])
        
        if subscription_type == "consumable"
            iap_type = Spaceship::Tunes::IAPType::CONSUMABLE
        elsif subscription_type == "non_consumable"
            iap_type = Spaceship::Tunes::IAPType::NON_CONSUMABLE
        elsif subscription_type == "non_renew_subscription"
            iap_type = Spaceship::Tunes::IAPType::NON_RENEW_SUBSCRIPTION
        else
            raise Exception.new "\u001b[31mWrong subscription type (valid duration values ==> consumable, non_consumable, non_renew_subscription)\nrenew_subscription pls use another lane 👿"
        end

        if merch_pic_url
            open('merch.png', 'wb') do |file|
                file << open(merch_pic_url).read
            end
            puts app.in_app_purchases.create!(
              type: iap_type,  # IAP Type
              versions: iap_version_dict,
              reference_name: reference_name,  #Reference Name
              product_id: product_id,   #IAP ID
              cleared_for_sale: cleared_flag,   #Cleared for Sale
              review_notes: review_notes,
              merch_screenshot: "merch.png",
              review_screenshot: "review.png",
              pricing_intervals:
                [
                  {
                    country: "WW",
                    begin_date: nil,
                    end_date: nil,
                    tier: price_tier,
                  }
                ]
            )
        else
            puts app.in_app_purchases.create!(
                          type: iap_type,  # IAP Type
                          versions: iap_version_dict,
                          reference_name: reference_name,  #Reference Name
                          product_id: product_id,   #IAP ID
                          cleared_for_sale: cleared_flag,   #Cleared for Sale
                          review_notes: review_notes,
                          review_screenshot: "review.png",
                          pricing_intervals:
                            [
                              {
                                country: "WW",
                                begin_date: nil,
                                end_date: nil,
                                tier: price_tier
                              }
                            ]
                        )
        end
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
                                       env_name: "FL_NORMAL_SUBSCRIPTION_API_TOKEN", # The name of the environment variable
                                       description: "API Token for NormalSubscriptionAction"),
          FastlaneCore::ConfigItem.new(key: :reference_name,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :review_notes,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :price_tier,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       type: Integer,
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :review_pic_url,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :merch_pic_url,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :cleared_flag,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :iap_version_dict,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :subscription_type,
                                       env_name: "FL_NORMAL_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one")
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['NORMAL_SUBSCRIPTION_CUSTOM_VALUE', 'A description of what this value contains']
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
