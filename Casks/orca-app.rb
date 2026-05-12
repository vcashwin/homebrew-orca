cask "orca-app" do
  version "0.1.2"
  sha256 "932329db9ab3ce86b902d20feb0bea694f2d1fc1d1d9254bcaff579b5ef04aea"

  url "https://github.com/vcashwin/orca-releases/releases/download/v#{version}/Orca-#{version}.dmg"
  name "Orca"
  desc "Desktop UI for parallel AI coding sessions"
  homepage "https://github.com/vcashwin/orca"

  depends_on macos: ">= :ventura"
  depends_on formula: "vcashwin/orca/orca"

  app "Orca.app"

  preflight do
    # Docker Desktop is a runtime requirement, but users frequently install it
    # from docker.com instead of via brew. A hard `depends_on cask: "docker"`
    # would refuse to install in that case (or try to reinstall Docker on top).
    # Detect any existing Docker.app in /Applications or ~/Applications; if
    # none is present, install it via brew so the user gets a working stack
    # without needing a second command.
    docker_paths = [
      "/Applications/Docker.app",
      File.expand_path("~/Applications/Docker.app")
    ]
    unless docker_paths.any? { |p| File.directory?(p) }
      ohai "Docker Desktop not found — installing via 'brew install --cask docker'"
      system_command "#{HOMEBREW_PREFIX}/bin/brew",
                     args: ["install", "--cask", "docker"],
                     print_stdout: true,
                     print_stderr: true,
                     sudo: false
    end
  end

  postflight do
    # Without an Apple Developer ID we ship an ad-hoc signed build, which
    # macOS Sequoia/Tahoe Gatekeeper rejects with "Check with the developer
    # to make sure Orca works with this version of macOS" on first launch.
    # Strip every extended attribute (covers com.apple.quarantine and any
    # provenance metadata Gatekeeper may consult) and re-apply an ad-hoc
    # signature so the bundle's integrity matches its current contents.
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Orca.app"],
                   sudo: false
    system_command "/usr/bin/codesign",
                   args: ["--force", "--deep", "--sign", "-", "#{appdir}/Orca.app"],
                   sudo: false
  end

  uninstall quit: "com.orca.desktop"

  zap trash: [
    "~/Library/Application Support/Orca",
    "~/Library/Preferences/com.orca.desktop.plist",
    "~/Library/Logs/Orca",
  ]
end
