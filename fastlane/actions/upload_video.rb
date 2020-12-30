module Fastlane
  module Actions
    module SharedValues
      UPLOAD_VIDEO_CUSTOM_VALUE = :UPLOAD_VIDEO_CUSTOM_VALUE
    end

    class UploadVideoAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "💖💗💖💗 BEGIN 💖💗💖💗"
        UI.message "🍭 \u001b[36;1mUpload video app preview"
        video_path = params[:video_path]
        language = params[:language]
        video_position = params[:video_position]
        
        UI.message("find video_path:#{video_path} 🌸")
        UI.message("find language:#{language} 🌸")
        
        Spaceship::Tunes.login($FASTLANE_USER, $FASTLANE_PASSWORD)
        app = Spaceship::ConnectAPI::App.find(ENV['APP_IDENTIFIER'])
               
        app_version = app.get_edit_app_store_version(platform:Spaceship::ConnectAPI::Platform::IOS)
        localizations = app_version.get_app_store_version_localizations
        if language != ""
            localizations.each do |localization|
                lan = localization.locale
                if lan == language
                    puts "Only update video app preview on #{language}"
                    upload_video(localization, lan, video_path, video_position)
                end
            end
        else
            puts "Update video app preview on all languages"
            localizations.each do |localization|
                lan = localization.locale
                upload_video(localization, lan, video_path, video_position)
            end
        end #language
        UI.message "👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏👏"
      end

      def self.upload_video(localization, lan, video_path, video_position)
          preview_sets = localization.get_app_preview_sets
          #Spaceship::ConnectAPI::AppPreviewSet::PreviewType::ALL.each do |preview_type|
          if video_path.include?("1080")
              preview_types = ["IPHONE_35", "IPHONE_40", "IPHONE_47", "IPHONE_55"]
          elsif video_path.include?("886")
              preview_types = ["IPHONE_65"]
          elsif video_path.include?("1200") or video_path.include?("1600")
              preview_types = ["IPAD_PRO_129", "IPAD_PRO_3GEN_129"]
          else
              preview_types = ["Not Found"]
          end
          puts preview_types
          puts "------------------------------------"
          preview_types.each do |preview_type|
              puts("Process preview type #{preview_type}")

              # find the preview set for this type
              preview_set = preview_sets.find do |set|
                  set.preview_type == preview_type
              end
              # delete all existing previews
              if preview_set and !preview_set.app_previews.empty?
                  preview_set.app_previews.each do |app_preview|
                      puts("Deleting #{app_preview.id}")
                      app_preview.delete!
                  end
              end
              if preview_set.nil?
                  preview_set = localization.create_app_preview_set(attributes: {previewType: preview_type})
              end
              puts preview_set.upload_preview(path: video_path, wait_for_processing: false, position: video_position)
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
          FastlaneCore::ConfigItem.new(key: :video_position,
                                       env_name: "FL_UPLOAD_VIDEO_API_TOKEN", # The name of the environment variable
                                       description: "API Token for UploadVideoAction"),
          FastlaneCore::ConfigItem.new(key: :language,
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
