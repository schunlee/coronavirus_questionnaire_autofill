require 'fileutils'

source_dir = ENV["BITRISE_SOURCE_DIR"] # /Users/vagrant/git
project_dir = "#{source_dir}/proj.android-studio"

def find_insert_position(file_content, target_str, pos_adujst)
    file_content.each_line.with_index do |line, line_num|
        if line.include?(target_str)
            return line_num + pos_adujst
        end
    end
    return nil
end


puts "0️⃣ \u001b[36;1mto modify app/build.gradle"
app_gradle_pth = ""
Dir.glob(["**/app/build.gradle"]).each do|f|
    app_gradle_pth = File.expand_path(f)
    puts "the absolute path of app/build.gradle: #{app_gradle_pth} 🌸"
end
if app_gradle_pth == ""
    raise Exception.new "\n\u001b[31mCannot find app/build.gradle 👿"
end

app_gradle_content=File.open(app_gradle_pth).read
insert_index = find_insert_position(app_gradle_content, "plugins", 1)
if insert_index
    app_gradle_lines = app_gradle_content.split("\n")
    app_gradle_lines.insert(insert_index, "    id 'com.github.triplet.play'")
end

insert_index = find_insert_position(app_gradle_content, "apply plugin", 1)
if insert_index
    app_gradle_lines = app_gradle_content.split("\n")
    app_gradle_lines.insert(insert_index, "    apply plugin: 'com.github.triplet.play'")
end

app_gradle_content = app_gradle_lines.join("\n")

insert_index = find_insert_position(app_gradle_content, "dependencies", -1)
if insert_index
    app_gradle_lines = app_gradle_content.split("\n")
    app_gradle_lines.insert(insert_index, 'play {serviceAccountCredentials = file("google-play-auto-publisher.json")}')
end

app_gradle_content = app_gradle_lines.join("\n")
puts app_gradle_content

File.open(app_gradle_pth, "w") { |f| f.write app_gradle_content }

puts "1️⃣ \u001b[36;1mto modify project root build.gradle"
proj_gradle_pth = ""
Dir.glob(["**/build.gradle"]).each do|f|
    _pth = File.expand_path(f)
    if _pth != app_gradle_pth
       proj_gradle_pth = _pth
       puts "the absolute path of project build.gradle: #{proj_gradle_pth} 🌸"
    end
end
if proj_gradle_pth == ""
    raise Exception.new "\n\u001b[31mCannot find project build.gradle 👿"
end

proj_gradle_content=File.open(proj_gradle_pth).read
insert_index = find_insert_position(proj_gradle_content, "dependencies", 1)
if insert_index
    proj_gradle_lines = proj_gradle_content.split("\n")
    proj_gradle_lines.insert(insert_index, '        classpath "com.github.triplet.gradle:play-publisher:2.4.0"')
end
proj_gradle_content = proj_gradle_lines.join("\n")
insert_index = find_insert_position(proj_gradle_content, "buildscript", 3)
if insert_index
    proj_gradle_lines = proj_gradle_content.split("\n")
    proj_gradle_lines.insert(insert_index, "        maven { url 'https://plugins.gradle.org/m2/' }")
end
proj_gradle_content = proj_gradle_lines.join("\n")
puts proj_gradle_content

File.open(proj_gradle_pth, "w") { |f| f.write proj_gradle_content }


key_content = ENV['ANDROID_PUBLISHER_CREDENTIALS']
puts key_content
File.open("#{project_dir}/app/google-play-auto-publisher.json", "w") { |f| f.write key_content }
puts File.open("#{project_dir}/app/google-play-auto-publisher.json").read

puts "2️⃣ \u001b[36;1mcreate metadata resources dir"

path_list = [
    "#{project_dir}/app/src/main/play",
    "#{project_dir}/app/src/main/play/listings",
]

["en-US", "zh-CN", "zh-HK", "zh-TW"].each do |lan|
#["en-US"].each do |lan|
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}")
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}/graphics")
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}/graphics/phone-screenshots")
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}/graphics/tablet-screenshots")
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}/graphics/large-tablet-screenshots")
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}/graphics/icon")
    path_list.append("#{project_dir}/app/src/main/play/listings/#{lan}/graphics/feature-graphic")
end

path_list.each do |element|
  Dir.mkdir(element)
end

icon_file_name = ENV['ANDROID_PUBLISHER_CN_ICON']
if icon_file_name
    puts "3️⃣ 🇨🇳 \u001b[36;1mcopy cn icon pic to target dirs"
    if File.exist?("#{source_dir}/postproduction/gp/store/icon/#{icon_file_name}")
        ["zh-CN", "zh-HK", "zh-TW"].each do |lan|
            FileUtils.cp("#{source_dir}/postproduction/gp/store/icon/#{icon_file_name}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/icon/icon.png")
        end
    else 
        raise Exception.new "\n\u001b[31mCannot find #{source_dir}/postproduction/gp/store/icon/#{icon_file_name} 👿"
    end
end

icon_file_name = ENV['ANDROID_PUBLISHER_US_ICON']
if icon_file_name
    puts "4️⃣ 🇺🇸 \u001b[36;1mcopy icon us pic to target dirs"
    puts "#{source_dir}/postproduction/gp/store/icon/#{icon_file_name}"
    if File.exist?("#{source_dir}/postproduction/gp/store/icon/#{icon_file_name}")
        ["en-US"].each do |lan|
            FileUtils.cp("#{source_dir}/postproduction/gp/store/icon/#{icon_file_name}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/icon/icon.png")
        end
    else 
        raise Exception.new "\n\u001b[31mCannot find #{source_dir}/postproduction/gp/store/icon/#{icon_file_name} 👿"
    end
end


feature_file_name = ENV['ANDROID_PUBLISHER_CN_FEATURE']
if feature_file_name
    puts "5️⃣ 🇨🇳 \u001b[36;1mcopy cn feature-graphic pic to target dirs"
    puts "#{source_dir}/postproduction/gp/store/fg/#{feature_file_name}"
    if File.exist?("#{source_dir}/postproduction/gp/store/fg/#{feature_file_name}")
        ["zh-CN", "zh-HK", "zh-TW"].each do |lan|
            FileUtils.cp("#{source_dir}/postproduction/gp/store/fg/#{feature_file_name}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/feature-graphic/feature-graphic.png")
        end
    else
        raise Exception.new "\n\u001b[31mCannot find #{source_dir}/postproduction/gp/store/fg/#{feature_file_name} 👿"
    end
end

feature_file_name = ENV['ANDROID_PUBLISHER_US_FEATURE']
if feature_file_name
    puts "6️⃣ 🇺🇸 \u001b[36;1mcopy us feature-graphic pic to target dirs"
    puts "#{source_dir}/postproduction/gp/store/fg/#{feature_file_name}"
    if File.exist?("#{source_dir}/postproduction/gp/store/fg/#{feature_file_name}")
        ["en-US"].each do |lan|
            FileUtils.cp("#{source_dir}/postproduction/gp/store/fg/#{feature_file_name}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/feature-graphic/feature-graphic.png")
        end
    else
        raise Exception.new "\n\u001b[31mCannot find #{source_dir}/postproduction/gp/store/fg/#{feature_file_name} 👿"
    end
end


screen_cn_file_names = ENV['ANDROID_PUBLISHER_CN_SS']
if screen_cn_file_names
    puts "7️⃣ 🇨🇳 \u001b[36;1mcopy cn screenshots pic to target dirs"
    puts "#{source_dir}/postproduction/gp/store/screenshots/cn/2048x2732/#{screen}"
    screen_cn_file_names.split(",").each do |screen|
        screen = screen.strip
        if File.exist?("#{source_dir}/postproduction/gp/store/screenshots/cn/2048x2732/#{screen}")
            ["zh-CN", "zh-HK", "zh-TW"].each do |lan|
                FileUtils.cp("#{source_dir}/postproduction/gp/store/screenshots/cn/2048x2732/#{screen}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/phone-screenshots")
                FileUtils.cp("#{source_dir}/postproduction/gp/store/screenshots/cn/2048x2732/#{screen}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/tablet-screenshots")
                FileUtils.cp("#{source_dir}/postproduction/gp/store/screenshots/cn/2048x2732/#{screen}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/large-tablet-screenshots")
            end
        else
            raise Exception.new "\n\u001b[31mCannot find #{source_dir}/postproduction/gp/store/screenshots/cn/2048x2732/#{screen} 👿"
        end
    end
end


screen_us_file_names = ENV['ANDROID_PUBLISHER_US_SS']
if screen_us_file_names
    puts "8️⃣ 🇺🇸 \u001b[36;1mcopy us screenshots pic to target dirs"
    puts "#{source_dir}/postproduction/gp/store/screenshots/en/2048x2732/#{screen}"
    screen_us_file_names.split(",").each do |screen|
        screen = screen.strip
        if File.exist?("#{source_dir}/postproduction/gp/store/screenshots/en/2048x2732/#{screen}")
            ["en-US"].each do |lan|
                FileUtils.cp("#{source_dir}/postproduction/gp/store/screenshots/en/2048x2732/#{screen}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/phone-screenshots")
                FileUtils.cp("#{source_dir}/postproduction/gp/store/screenshots/en/2048x2732/#{screen}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/tablet-screenshots")
                FileUtils.cp("#{source_dir}/postproduction/gp/store/screenshots/en/2048x2732/#{screen}", "#{project_dir}/app/src/main/play/listings/#{lan}/graphics/large-tablet-screenshots")
            end
        else
            raise Exception.new "\n\u001b[31mCannot find #{source_dir}/postproduction/gp/store/screenshots/us/2048x2732/#{screen} 👿"
        end
    end
end
