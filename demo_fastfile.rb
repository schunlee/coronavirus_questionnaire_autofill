            # This file contains the fastlane.tools configuration
            # You can find the documentation at https://docs.fastlane.tools
            #
            # For a list of all available actions, check out
            #
            #     https://docs.fastlane.tools/actions
            #
            # For a list of all available plugins, check out
            #
            #     https://docs.fastlane.tools/plugins/available-plugins
            #

            # Uncomment the line if you want fastlane to automatically update itself
            # update_fastlane

            default_platform(:ios)

            platform :ios do
              desc "Description of what the lane does"
              lane :custom_lane do
                # add actions here: https://docs.fastlane.tools/actions
              end

              desc "Upload to App Store and submit for review"
              lane :upload do
                deliver(
                   username: ENV['APPLE_ID'],
                   app_identifier: ENV['APP_IDENTIFIER'],
                   app_version:"1.0",
                   precheck_include_in_app_purchases: true,
                )
              end

            # Function 1
              desc "Upload metadata and ipa to App Store"
              lane :do_everything do
                upload
              end

            # Function 2
              desc "Only upload metadata to App Store"
              
              lane :update_meta do
                 import_from_git(url: 'https://github.com/schunlee/coronavirus_questionnaire_autofill.git', branch: 'main')
                 deliver(
                   username: ENV['APPLE_ID'],
                   app_identifier: ENV['APP_IDENTIFIER'],
                   app_version: "1.0",
                   skip_binary_upload: true,
                   #SCREENSHOTS_PLACEHOLDER
                   #METADATA_PLACEHOLDER
                   #PHASED_RELEASE_PLACEHOLDER
                   #VERSION_RELEASE_PLACEHOLDER
                   #PRICE_TIER_PLACEHOLDER
                   #RESET_RATINGS_PLACEHOLDER
                   #SUBMISSION_INFORMATION_PLACEHOLDER
                )
                  ##PRE_ORDER_PLACEHOLDER
                  #BILLING_GRACE_PERIOD_PLACEHOLDER
                  #SERVER_URL_PLACEHOLDER
                  ##AVAILABILITY_PLACEHOLDER
                  
                  
              end

            # Function 3
              desc "Only upload iap to App Store"
              lane :update_ipa do
                 deliver(
                   username: ENV['APPLE_ID'],
                   app_identifier: ENV['APP_IDENTIFIER'],
                   app_version: "1.0",
                   skip_screenshots: true,
                   skip_metadata: true,
                )
              end

            end
