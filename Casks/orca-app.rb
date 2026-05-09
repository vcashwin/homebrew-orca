cask "orca-app" do
  version "0.1.0"
  sha256 "63e6678edef7ddec30d0b7762d247903ee4421da89c82fc16af03fde206e7b33"

  url "https://github.com/vcashwin/orca-releases/releases/download/v#{version}/Orca-#{version}.dmg"
  name "Orca"
  desc "Desktop UI for parallel AI coding sessions"
  homepage "https://github.com/vcashwin/orca"

  depends_on macos: ">= :ventura"
  depends_on formula: "vcashwin/orca/orca"
  depends_on cask: "docker"

  app "Orca.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Orca.app"],
                   sudo: false
  end

  uninstall quit: "com.orca.desktop"

  zap trash: [
    "~/Library/Application Support/Orca",
    "~/Library/Preferences/com.orca.desktop.plist",
    "~/Library/Logs/Orca",
  ]
end
