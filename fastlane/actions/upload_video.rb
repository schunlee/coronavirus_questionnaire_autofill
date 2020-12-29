module Fastlane
  module Actions
    module SharedValues
      UPLOAD_VIDEO_CUSTOM_VALUE = :UPLOAD_VIDEO_CUSTOM_VALUE
    end

    class UploadVideoAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        video_path = params[:video_path]
        language = params[:language]
        size = params[:size]

        UI.message("find video_path:#{video_path} 🌸")
        UI.message("find language:#{language} 🌸")
        UI.message("find size:#{size} 🌸")
        
        SIZE_PREVIEW_DICT = {:2208 => ["IPHONE_35", "IPHONE_40", "IPHONE_47", "IPHONE_55"],
                             :2688 => ["IPHONE_65"],
                             :2732 => ["IPAD_PRO_129", "IPAD_PRO_3GEN_129"]
                            }

        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::ConnectAPI::App.find(ENV['APP_IDENTIFIER'])

        app_version = app.get_edit_app_store_version(platform:Spaceship::ConnectAPI::Platform::IOS)
        localizations = app_version.get_app_store_version_localizations
        if language != ""
            localizations.each do |localization|
                lan = localization.locale
                if lan == language
                    puts "Only update video app preview on #{language}"
                    upload_video(localization, lan, size, video_path)
                end
            end
        else
            puts "Only update video app preview on all languages"
            localizations.each do |localization|
                lan = localization.locale
                upload_video(localization, lan, size, video_path)
            end
        end #language

      end

      def self.upload_video(localization, lan, size, video_path)
          preview_sets = localization.get_app_preview_sets
          #Spaceship::ConnectAPI::AppPreviewSet::PreviewType::ALL.each do |preview_type|
          preview_types = SIZE_PREVIEW_DICT[:size]
          puts preview_types
          preview_types.each do |preview_type|
              puts("Process preview type #{preview_type}")

              # find the preview set for this type
              preview_set = preview_sets.find do |set|
                  set.preview_type == preview_type
              end
              # delete all existing previews
              if !preview_set.app_previews.empty?
                  preview_set.app_previews.each do |app_preview|
                      puts("Deleting #{app_preview.id}")
                      app_preview.delete!
                  end
              end
              if preview_set.nil?
                  #puts("Skipping #{lan} >>> #{preview_type}; not create first in app store")
                  #next
                  preview_set = localization.create_app_preview_set(attributes: {previewType: preview_type})
              end
              puts preview_set.upload_preview(path: video_path, wait_for_processing: false)
              puts "video #{video_path} be uploaded on App Store (language >> #{lan})"
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
          FastlaneCore::ConfigItem.new(key: :video_path,
                                       env_name: "FL_UPLOAD_VIDEO_API_TOKEN", # The name of the environment variable
                                       description: "API Token for UploadVideoAction"),
          FastlaneCore::ConfigItem.new(key: :language,
                                       env_name: "FL_UPLOAD_VIDEO_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one"),
          FastlaneCore::ConfigItem.new(key: :size,
                                       env_name: "FL_UPLOAD_VIDEO_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one")
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['UPLOAD_VIDEO_CUSTOM_VALUE', 'A description of what this value contains']
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
