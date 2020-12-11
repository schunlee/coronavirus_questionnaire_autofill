require 'spaceship'
require 'open-uri'
require 'faraday'

module Fastlane
  module Actions
    module SharedValues
      AUTO_RENEWABLE_SUBSCRIPTION_CUSTOM_VALUE = :AUTO_RENEWABLE_SUBSCRIPTION_CUSTOM_VALUE
    end

    class AutoRenewableSubscriptionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        UI.message "🍭 \u001b[36;1mCreate Auto Renewable Subscription Group & IAP"
        group_name = params[:group_name]
        reference_name = params[:reference_name]
        product_id = params[:product_id]
        review_pic_url = params[:review_pic_url]
        merch_pic_url = params[:merch_pic_url]
        review_notes = params[:review_notes]
        group_version_dict = params[:group_version_dict]
        iap_version_dict = params[:iap_version_dict]
        duration = params[:duration]
        price_tier = params[:price_tier]
        cleared_flag = params[:cleared_flag]
        
        if cleared_flag == "true"
            cleared_flag = true
        else
            cleared_flag = false
        end

        UI.message("find parameter >> group_name:#{group_name} 🌸")
        UI.message("find parameter >> reference_name:#{reference_name} 🌸")
        UI.message("find parameter >> product_id:#{product_id} 🌸")
        UI.message("find parameter >> review_pic_url:#{review_pic_url} 🌸")
        UI.message("find parameter >> merch_pic_url:#{merch_pic_url} 🌸")
        UI.message("find parameter >> review_notes:#{review_notes} 🌸")
        UI.message("find parameter >> duration:#{duration} 🌸")
        UI.message("find parameter >> price_tier:#{price_tier} 🌸")
        UI.message("find parameter >> cleared_flag:#{cleared_flag} 🌸")
        UI.message("find parameter >> group_version_dict:#{group_version_dict} 🌸")
        UI.message("find parameter >> iap_version_dict:#{iap_version_dict} 🌸")
        
        if not ["1w", "1m", "2m", "3m", "6m", "1y"].map{|e|e}.include? duration
            raise Exception.new "\u001b[31mWrong duration for IAP (valid duration values ==> 1w, 1m, 2m, 3m, 6m, 1y) 👿"
        end

        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::Application.find(ENV['APP_IDENTIFIER'])

        groups = app.in_app_purchases.families.all


        for i in 0..groups.size - 1
            if groups.at(i).name == group_name
                UI.message "🈶 Subscription Group (#{group_name}) Existed."
                family_id = groups.at(i).family_id
                UI.message "⏳ Creating iap ..."
                create_auto_renew_subscription(app, family_id, reference_name, product_id, cleared_flag, review_notes, merch_pic_url, review_pic_url, duration, price_tier, iap_version_dict)
            end
        end

        #if cannot find target subscription group, need to create one
        if not groups.map{|e|e.name}.include? group_name
            UI.message "🈳 Subscription Group (#{group_name}) NonExisted, so now creating it."
            create_family(app, group_name, reference_name, product_id, group_version_dict)
            UI.message "⏳ Updating default iap configs ..."
            sleep(10)
            update_auto_renew_subscription(app, product_id, iap_version_dict, cleared_flag, duration, price_tier, review_notes, review_pic_url, merch_pic_url)
            # to make sure update successfully
            update_auto_renew_subscription(app, product_id, iap_version_dict, cleared_flag, duration, price_tier, review_notes, review_pic_url, merch_pic_url)
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
          FastlaneCore::ConfigItem.new(key: :group_name,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_API_TOKEN", # The name of the environment variable
                                       description: "API Token for AutoRenewableSubscriptionAction"), # a short description of this parameter),
          FastlaneCore::ConfigItem.new(key: :reference_name,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :product_id,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :review_pic_url,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :merch_pic_url,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :review_notes,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :duration,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :price_tier,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :cleared_flag,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :group_version_dict,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       type: Hash
                                       ),
          FastlaneCore::ConfigItem.new(key: :iap_version_dict,
                                       env_name: "FL_AUTO_RENEWABLE_SUBSCRIPTION_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       type: Hash
                                       )
        ]
      end


      def self.update_auto_renew_subscription(app, product_id, version_dict, cleared_flag, subscription_duration, subscription_price_tier, review_notes, review_pic_url, merch_pic_url)
          app.in_app_purchases.all.each do | purch |
            puts purch.product_id
            if purch.product_id == product_id
               e = purch.edit
               puts e
               e.versions = version_dict
               e.cleared_for_sale = cleared_flag
               e.subscription_duration =  subscription_duration
               e.subscription_price_target = {currency: "USD", tier: subscription_price_tier}
               e.review_notes = review_notes
               if review_pic_url
                   open("review.png", "wb") do |file|
                       file << open(review_pic_url).read
                   end
                   e.review_screenshot = "review.png"
               end
               if merch_pic_url
                   open("merch.png", "wb") do |file|
                       file << open(merch_pic_url).read
                   end
                   e.merch_screenshot = "merch.png"
               end
               puts e.save!
             end
           end
      end


      def self.create_family(app, family_name, iap_reference_name, iap_product_id, family_version)
          puts app.in_app_purchases.families.create!(
                                                reference_name: iap_reference_name,
                                                product_id: iap_product_id,
                                                name: family_name,
                                                versions: family_version
                                                 )
      end


      def self.create_auto_renew_subscription(app, family_id, reference_name, product_id, cleared_flag, review_notes, merch_pic_url, review_pic_url, subscription_duration, subscription_price_tier, version_dict)
          open("review.png", "wb") do |file|
              file << open(review_pic_url).read
          end
          if merch_pic_url
              open("merch.png", "wb") do |file|
                  file << open(merch_pic_url).read
              end
              puts app.in_app_purchases.create!(type: Spaceship::Tunes::IAPType::RECURRING,
                            versions: version_dict,
                            reference_name: reference_name,
                            product_id: product_id,
                            cleared_for_sale: cleared_flag,
                            review_notes: review_notes,
                            merch_screenshot: "merch.png",
                            review_screenshot: "review.png",
                            subscription_price_target: {currency: "USD", tier: subscription_price_tier},
                            subscription_duration: subscription_duration,
                            family_id: family_id,
                           )
            else
                puts app.in_app_purchases.create!(type: Spaceship::Tunes::IAPType::RECURRING,
                            versions: version_dict,
                            reference_name: reference_name,
                            product_id: product_id,
                            cleared_for_sale: cleared_flag,
                            review_notes: review_notes,
                            review_screenshot: "review.png",
                            subscription_price_target: {currency: "USD", tier: subscription_price_tier},
                            subscription_duration: subscription_duration,
                            family_id: family_id,
                           )
            end
      end





      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['AUTO_RENEWABLE_SUBSCRIPTION_CUSTOM_VALUE', 'A description of what this value contains']
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
