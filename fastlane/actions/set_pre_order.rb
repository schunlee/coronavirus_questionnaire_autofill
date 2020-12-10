require 'spaceship'
module Fastlane
  module Actions
    module SharedValues
      SET_PRE_ORDER_CUSTOM_VALUE = :SET_PRE_ORDER_CUSTOM_VALUE
    end

    class SetPreOrderAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        pre_order_flag = params[:pre_order_flag]
        if pre_order_flag == "true"
           pre_order_flag = true
        else
           pre_order = false
        end
        UI.message("find parameter >> pre_order_flag:#{pre_order_flag} 🌸")
        pre_order_date = params[:pre_order_date]
        UI.message("find parameter >> pre_order_date:#{pre_order_date} 🌸")

        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::Application.find(ENV['APP_IDENTIFIER'])
        #puts app
        app_id = app.apple_id
        app1 = Spaceship::ConnectAPI.get_app(app_id: app_id).first
        puts "^^^^^^^^^^^^^^^^^^^^"
        puts app1.prices
        puts "^^^^^^^^^^^^^^^^^^^^"
        puts app1.update()
        availability = app.availability
        availability.cleared_for_preorder = pre_order_flag
        if pre_order_flag.to_s == "false"
            availability.app_available_date = nil
        else
            availability.app_available_date = pre_order_date
        end
        puts app.update_availability!(availability)
        #begin
        #    puts app.update_availability!(availability)
        #rescue Exception => e
        #    puts e
        #end
        UI.message "💯 💯 💯"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Open or close pre-order, and set pre-order date"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Open or close pre-order, and set pre-order date"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :pre_order_flag,
                                       env_name: "PRE_ORDER_FLAG", # The name of the environment variable
                                       description: "Flag for SetPreOrderAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No Flag for SetPreOrderAction given, pass using `flag: 'pre_order_flag'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :pre_order_date,
                                       env_name: "PRE_ORDER_DATE",
                                       description: "Pre_order date")
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['SET_PRE_ORDER_CUSTOM_VALUE', 'A description of what this value contains']
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
