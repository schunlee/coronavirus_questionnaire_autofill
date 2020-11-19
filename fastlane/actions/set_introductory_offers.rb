require 'spaceship'
require 'faraday'
require 'json'

module Fastlane
  module Actions
    module SharedValues
      SET_INTRODUCTORY_OFFERS_CUSTOM_VALUE = :SET_INTRODUCTORY_OFFERS_CUSTOM_VALUE
    end

    class SetIntroductoryOffersAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        product_id = params[:product_id]
        us_tier_num = params[:us_tier_num]
        duration_periods = params[:duration_periods]
        offer_type = params[:offer_type] # FreeTrial, PayAsYouGo, PayUpFront
        
        countries_list = ['AF', 'AL', 'DZ', 'AO', 'AI', 'AG', 'AR', 'AM', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BA', 'BW', 'BR', 'VG', 'BN', 'BG', 'BF', 'KH', 'CM', 'CA', 'CV', 'KY', 'TD', 'CL', 'CN', 'CO', 'CD', 'CG', 'CR', 'CI', 'HR', 'CY', 'CZ', 'DK', 'DM', 'DO', 'EC', 'EG', 'SV', 'EE', 'SZ', 'FJ', 'FI', 'FR', 'GA', 'GM', 'GE', 'DE', 'GH', 'GR', 'GD', 'GT', 'GW', 'GY', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IQ', 'IE', 'IL', 'IT', 'JM', 'JP', 'JO', 'KZ', 'KE', 'KR', 'XK', 'KW', 'KG', 'LA', 'LV', 'LB', 'LR', 'LY', 'LT', 'LU', 'MO', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MR', 'MU', 'MX', 'FM', 'MD', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NZ', 'NI', 'NE', 'NG', 'MK', 'NO', 'OM', 'PK', 'PW', 'PA', 'PG', 'PY', 'PE', 'PH', 'PL', 'PT', 'QA', 'RO', 'RU', 'RW', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'SK', 'SI', 'SB', 'ZA', 'ES', 'LK', 'KN', 'LC', 'VC', 'SR', 'SE', 'CH', 'TW', 'TJ', 'TZ', 'TH', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'UG', 'UA', 'AE', 'GB', 'US', 'UY', 'UZ', 'VU', 'VE', 'VN', 'YE', 'ZM', 'ZW']
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

        purch_id = ""
        intro = nil

        app.in_app_purchases.all.each do | purch |
            if purch.product_id == product_id
                intro = purch.edit.raw_pricing_data["introOffers"]
                if not purch.edit.subscription_duration
                    raise Exception.new "\u001b[31mSubscription Duration is blank, pls set it first👿"  
                end
                if not purch.edit.raw_pricing_data["subscriptions"]
                    raise Exception.new "\u001b[31mSubscription Price is blank, pls set it first👿"  
                end
                purch_id = purch.edit.purchase_id
                app_id = app.apple_id

                if offer_type == "FreeTrial"
                    if not ["3d", "1w", "2w", "1m", "2m", "3m", "6m", "1y"].map{|e|e}.include? duration_periods
                        raise Exception.new "\u001b[31mWrong duration periods for FreeTrial (valid duration values ==> 3d, 1w, 2w, 1m, 2m, 3m, 6m, 1y) 👿"
                    end
                    duration_type = duration_periods
                    num_of_periods = "1"
                    auto_tier_flag = false

                elsif offer_type == "PayUpFront"
                    if not ["1m", "2m", "3m", "6m", "1y"].map{|e|e}.include? duration_periods
                        raise Exception.new "\u001b[31mWrong duration periods for PayUpFront (valid duration values ==> 1m, 2m, 3m, 6m, 1y) 👿"
                    end
                    duration_type = duration_periods
                    num_of_periods = "1"
                    auto_tier_flag = true
                elsif offer_type == "PayAsYouGo"
                    if not ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "10m", "11m", "12m"].map{|e|e}.include? duration_periods
                        raise Exception.new "\u001b[31mWrong duration periods for PayAsYouGo (valid duration values ==> 1m, 2m, 3m, 4m, 5m, 6m, 7m, 8m, 9m, 10m, 11m, 12m) 👿"
                    end
                    duration_type = "1m"
                    num_of_periods = duration_periods.sub("m", "")
                    auto_tier_flag = true
                else
                    raise Exception.new "\u001b[31mWrong offer type 👿"
                end

                UI.message("find offer_type:#{offer_type} 🌸")
                UI.message("find duration_type:#{duration_type} 🌸")
                UI.message("find num_of_periods:#{num_of_periods} 🌸")
                UI.message("find auto_tier_flag:#{auto_tier_flag} 🌸")


                time = Time.new
                today_date = time.strftime("%Y-%m-%d")
                auto_tier_dict = {}
                if us_tier_num
                    auto_tier_dict = get_auto_tier(cookies, app_id, purch_id, us_tier_num, countries_list)
                end
                base_intro = wrap_update_payload(app_id, purch_id, duration_type, num_of_periods, offer_type, auto_tier_flag, today_date, nil, countries_list, auto_tier_dict)

                puts update_introductory_offers(cookies, app_id, purch_id, base_intro)
            end
        end
      end
      
      def self.update_introductory_offers(cookies, app_id, purch_id, intro)
           resp = Faraday.post("https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/iaps/pricing/batch",
                              {"batch": intro}.to_json,
                              {"Accept" => "application/json, text/plain, */*",
                               "Content-Type" => "application/json;charset=UTF-8",
                               "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
                               "Cookie" => cookies ,
                              })
            return JSON.parse resp.body
        end
      
      def self.wrap_update_payload(app_id, purch_id, duration_type, num_of_periods, offer_mode_type, auto_tier_flag, start_date, end_date, countries_list, auto_tier_dict)
           data_list = []
           countries_list.each do |country|
               data_list.append({"method": "PUT",
                                 "path": "/apps/#{app_id}/iaps/#{purch_id}/pricing/intro-offers/#{country}",
                                 "value": {
                                           "introOffers": ["errorKeys": nil,
                                                           "isEditable": true,
                                                           "isRequired": true,
                                                           "value": {"country": country,
        	                                                     "durationType": duration_type,
        	                                                     "numOfPeriods": num_of_periods,
        	                                                     "offerModeType": offer_mode_type,
        	                                                     "startDate": start_date,
        	                                                     "endDate": end_date,
        	                                                     "tierStem": if auto_tier_flag == false then nil else auto_tier_dict[country]["tierStem"] end}
                                                            ]
                                            }
                                  })
           end
           return data_list
        end
      
      def self.get_auto_tier(cookies, app_id, purch_id, tier_num, countries_list)
            countries = countries_list.join(",")
            resp = Faraday.get("https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/#{app_id}/iaps/#{purch_id}/pricing/equalize/USD/#{tier_num}",
                              {"countryCodes": countries},
                              {"Accept" => "application/json, text/plain, */*",
                               "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
                               "Cookie" => cookies ,
                              })
            resp_dict = JSON.parse resp.body
            return resp_dict["data"]
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
                                       env_name: "IAP_PRODUCT_ID", # The name of the environment variable
                                       description: "API Token for SetIntroductoryOffersAction"),
          FastlaneCore::ConfigItem.new(key: :us_tier_num,
                                       env_name: "US_TIER_NUM",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :duration_periods,
                                       env_name: "DURATION_PERIODS",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :offer_type,
                                       env_name: "OFFER_TYPE",
                                       description: "Create a development certificate instead of a distribution one")

        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['SET_INTRODUCTORY_OFFERS_CUSTOM_VALUE', 'A description of what this value contains']
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
