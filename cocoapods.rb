require 'git'
require 'terminal-table'

puts "0️⃣ \u001b[36;1msearch Podfile.lock/podfile.lock to delete"
Dir.glob(["**/Podfile.lock"]).each do|f|
    pod_lock_pth = File.expand_path(f)
    puts "the absolute path of Podfile.lock: #{pod_lock_pth} 🌸"
    puts File.delete(pod_lock_pth)
end

puts "1️⃣ \u001b[36;1msearch to get Podfile/podfile absolute path"
podfile_pth = ""
Dir.glob(["**/Podfile", "**/podfile"]).each do|f|
    podfile_pth = File.expand_path(f)
end
puts "the absolute path of Podfile: #{podfile_pth} 🌸"

if podfile_pth == ""
    raise Exception.new "\n\u001b[31mCannot find Podfile👿"
end

# read original content of podfile
p_file = File.open(podfile_pth)
podfile_content = p_file.read
p_file.close

puts "2️⃣ \u001b[36;1mread Podfile, to get source git url and sdk versions"
git_urls = []
base_name_list = []
versions = []

replacements = {'source' => '', "'" => '', '"' => '', '‘' => '', '’' => ''}
File.foreach(podfile_pth).with_index do |line, line_num|
   line = line.lstrip.rstrip
   if line.start_with?("source") and line.include?(".git") and not line.include?("CocoaPods/Specs")
       sdk_url = line.gsub(Regexp.union(replacements.keys), replacements).lstrip.rstrip
       sdk_name = sdk_url.split("/")[-1].split(".git")[0]
       git_urls.append(sdk_url)
       base_name_list.append(sdk_name)
   end
end

File.foreach(podfile_pth).with_index do |line, line_num|
   line = line.lstrip.rstrip
   if line.start_with?("pod")
       version = line.to_s[/([\d|\.]+)/,0]
       if line.include?("SSCUtilitySDK")
           base_sdk_name = "SSCUtilitySDK"
       elsif line.include?("SSCUnityLib")
           base_sdk_name = base_name_list.reject {|n| n == "SSCUtilitySDK"}[0]
       else
           next
       end
       versions.append({"base_name": base_sdk_name, "version": version})
   end
end

puts "sdk versions: #{versions} 🌸"


puts "3️⃣ \u001b[36;1mgit clone sdk to the local, and modify Podfile source git url"
git_urls.each do |item|
    base_name = item.split("/")[-1].split(".git")[0]
    replace_git_url = "http://***:*****@********/3rd-party/#{base_name}.git"
    podfile_content = podfile_content.gsub(item, "file:///Users/vagrant/git/#{base_name}")
    puts "git url: #{item} 🌸"
    puts Git.clone(replace_git_url, "/Users/vagrant/git/#{base_name}")
end

File.open(podfile_pth, "w") { |f| f.write podfile_content }

table = Terminal::Table.new do |t|
  t << ["Modified Podfile"]
  t << :separator
  t.add_row [podfile_content]
end
table.style = {:border_x => "*", :border_y => "|", :border_i => "*"}
puts table

puts "4️⃣ \u001b[36;1mmodify source git url of target version podspec"
versions.each do |item|
    puts "sdk_name => #{item[:base_name]} 🌸"
    if item[:base_name] == "SSCUtilitySDK"
        sdk_version = item[:version]
        sdk_name = item[:base_name]
        podsec_file_path = "/Users/vagrant/git/SSCUtilitySDK/SSCUtilitySDK/#{sdk_version}/SSCUtilitySDK.podspec"
    else
        sdk_version = item[:version]
        sdk_name = item[:base_name]
        podsec_file_path = "/Users/vagrant/git/#{sdk_name}/SSCUnityLib/#{sdk_version}/SSCUnityLib.podspec"
    end
    podsec_file = File.open(podsec_file_path)
    podsec_content = podsec_file.read
    podsec_content = podsec_content.gsub("git@github.stm.com:3rd-party/#{sdk_name}.git", "file:///Users/vagrant/git/#{sdk_name}")
    podsec_file.close
    File.open(podsec_file_path, "w") { |f| f.write podsec_content }
         
    table = Terminal::Table.new do |t|
        t << ["Modified Version Podsec"]
        t << :separator
        t.add_row [podsec_content]
    end
    table.style = {:border_x => "*", :border_y => "|", :border_i => "*"}
    puts table
    system("cd /Users/vagrant/git/#{sdk_name} && git add . && git commit -m 'modify by bill.li'")
end



system( "envman add --key PODFILE_PATH --value '#{podfile_pth}' " )
