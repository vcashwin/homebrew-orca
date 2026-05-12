class Orca < Formula
  desc "CLI to run the Orca local backend stack for AI coding sessions"
  homepage "https://github.com/vcashwin/orca"
  url "https://github.com/vcashwin/orca-releases/releases/download/v0.1.2/orca-cli-0.1.2.tar.gz"
  sha256 "387874bc3a40f15f4c7597a69b58530b4a0ccb1a9ade4ac1560f7cefbb4b379a"
  version "0.1.2"
  license "MIT"

  depends_on "bash"
  depends_on "curl"
  depends_on "jq"

  def install
    pkgshare.install "docker-compose.yml"

    # Inject the brew-managed compose path into the CLI so first-run can seed it.
    inreplace "bin/orca", 'BREW_COMPOSE_SRC="${BREW_COMPOSE_SRC:-}"',
              %Q(BREW_COMPOSE_SRC="${BREW_COMPOSE_SRC:-#{pkgshare}/docker-compose.yml}")

    # Default the image coordinates so 'docker compose pull' resolves correctly.
    inreplace "bin/orca", '#!/usr/bin/env bash',
              %Q(#!/usr/bin/env bash\nexport ORCA_IMAGE_REGISTRY="${ORCA_IMAGE_REGISTRY:-ghcr.io/vcashwin/orca}"\nexport ORCA_VERSION="${ORCA_VERSION:-#{version}}")

    bin.install "bin/orca"
  end

  def caveats
    <<~EOS
      The Orca CLI is installed. For the full beta stack you also need
      Docker Desktop and the Orca desktop app:

        brew install --cask docker
        brew install --cask vcashwin/orca/orca-app

      Then run:

        orca up

      This will:
        - Start Docker Desktop if it's not already running
        - Pull the Orca backend + worker images (first run only, ~1–2 min)
        - Start Postgres, Redis, and the Orca backend
        - Launch the Orca desktop app

      Resources live in: ~/.orca
      Tear down with:    orca stop
    EOS
  end

  test do
    assert_match "Usage: orca", shell_output("#{bin}/orca --help")
  end
end
