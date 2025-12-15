cask "framework-wallpapers" do
  version "2025-12-14"

  name "framework-wallpapers"
  desc "Wallpapers for Framework laptops"
  homepage "https://github.com/projectbluefin/artwork"

  livecheck do
    url "https://github.com/ublue-os/artwork.git"
    regex(/framework-v?(\d{4}-\d{2}-\d{2})/)
    strategy :github_releases
  end

  on_macos do
    url "https://github.com/ublue-os/artwork/releases/download/framework-v#{version}/framework-wallpapers-macos.tar.zstd"
    sha256 "e3afcfdbb919d84e02b0f99c2e450514db347bd4e7dd37e9fa23fdb72d321841"
  end

  on_linux do
    if File.exist?("/usr/bin/plasmashell")
      url "https://github.com/ublue-os/artwork/releases/download/framework-v#{version}/framework-wallpapers-kde.tar.zstd"
      sha256 "01225c2d24a8d14e4a42953889dcc6263050792a21f87b23346fb9ff6c13adf8"
    elsif File.exist?("/usr/bin/gnome-shell") || File.exist?("/usr/bin/mutter")
      url "https://github.com/ublue-os/artwork/releases/download/framework-v#{version}/framework-wallpapers-gnome.tar.zstd"
      sha256 "f936e03bd0486bab1ec1fdce30f93ff81fd49f949d8c9b878d51fa58dfa96524"
    else
      url "https://github.com/ublue-os/artwork/releases/download/framework-v#{version}/framework-wallpapers-png.tar.zstd"
      sha256 "2da39f34cb2131861da2adca1d03a6b25b0714b2e7d2686b4d14f7ed8c60e8eb"
    end
  end

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/Library/Desktop Pictures/Framework" if OS.mac?

    if OS.linux?
      FileUtils.mkdir_p "#{Dir.home}/.local/share/backgrounds/framework"
      FileUtils.mkdir_p "#{Dir.home}/.local/share/wallpapers/framework"
      FileUtils.mkdir_p "#{Dir.home}/.local/share/gnome-background-properties"

      Dir.glob("#{staged_path}/**/*.xml").each do |file|
        contents = File.read(file)
        contents.gsub!("~", Dir.home)
        File.write(file, contents)
      end
    end
  end

  postflight do
    if OS.mac?
      Dir.glob("#{staged_path}/*").each do |file|
        target = "#{Dir.home}/Library/Desktop Pictures/Framework/#{File.basename(file)}"
        FileUtils.ln_sf(file, target)
      end
      puts "Wallpapers installed to: #{Dir.home}/Library/Desktop Pictures/Framework"
      puts "To use: System Settings > Wallpaper > Add Folder"
    end

    if OS.linux?
      destination_dir = "#{Dir.home}/.local/share/backgrounds/framework"
      kde_destination_dir = "#{Dir.home}/.local/share/wallpapers/framework"

      if File.exist?("/usr/bin/plasmashell")
        Dir.glob("#{staged_path}/*").each do |file|
          target = "#{kde_destination_dir}/#{File.basename(file)}"
          FileUtils.ln_sf(file, target)
        end
      elsif File.exist?("/usr/bin/gnome-shell") || File.exist?("/usr/bin/mutter")
        Dir.glob("#{staged_path}/images/*").each do |file|
          target = "#{destination_dir}/#{File.basename(file)}"
          FileUtils.ln_sf(file, target)
        end

        Dir.glob("#{staged_path}/gnome-background-properties/*").each do |file|
          target = "#{Dir.home}/.local/share/gnome-background-properties/#{File.basename(file)}"
          FileUtils.ln_sf(file, target)
        end
      else
        Dir.glob("#{staged_path}/*").each do |file|
          target = "#{destination_dir}/#{File.basename(file)}"
          FileUtils.ln_sf(file, target)
        end
      end
    end
  end

  uninstall_postflight do
    FileUtils.rm_r "#{Dir.home}/Library/Desktop Pictures/Framework" if OS.mac?

    if OS.linux?
      FileUtils.rm_r "#{Dir.home}/.local/share/backgrounds/framework"
      FileUtils.rm_r "#{Dir.home}/.local/share/wallpapers/framework"
    end
  end

  zap trash: [
    "#{Dir.home}/.local/share/backgrounds/framework",
    "#{Dir.home}/.local/share/gnome-background-properties/framework-*.xml",
    "#{Dir.home}/.local/share/wallpapers/framework",
    "#{Dir.home}/Library/Desktop Pictures/Framework",
  ]
end
