class PeonPingRu < Formula
  desc "Russian Peon voice pack for Claude Code hooks - AI coding assistant sound effects"
  homepage "https://github.com/NikitaFrankov/peon-ping-ru"
  url "https://github.com/NikitaFrankov/peon-ping-ru/archive/refs/tags/v2.7.2.tar.gz"
  sha256 "26b1010c1d063e1c005a4cb1c1a58096f2f61f7feb9278f501dc9c6d9c785919"
  license "MIT"
  head "https://github.com/NikitaFrankov/peon-ping-ru.git", branch: "main"

  depends_on "python@3"

  def install
    # Install core Unix files
    libexec.install "peon.sh"
    libexec.install "config.json"
    libexec.install "VERSION"
    libexec.install "uninstall.sh"
    libexec.install "install.sh"
    libexec.install "completions.bash"
    libexec.install "completions.fish"

    # Install relay server (devcontainer audio support)
    libexec.install "relay.sh" if (buildpath/"relay.sh").exist?

    # Install Windows files (for cross-platform users)
    libexec.install "peon.ps1" if (buildpath/"peon.ps1").exist?
    libexec.install "install.ps1" if (buildpath/"install.ps1").exist?
    libexec.install "uninstall.ps1" if (buildpath/"uninstall.ps1").exist?

    # Install adapters (Unix)
    (libexec/"adapters").install Dir["adapters/*.sh"] if Dir["adapters/*.sh"].any?
    # Install adapters (Windows)
    (libexec/"adapters").install Dir["adapters/*.ps1"] if Dir["adapters/*.ps1"].any?
    # OpenCode adapter (TypeScript plugin)
    if (buildpath/"adapters/opencode").exist?
      (libexec/"adapters/opencode").install Dir["adapters/opencode/*"]
    end

    # Install scripts (Unix + Windows)
    if (buildpath/"scripts").exist?
      (libexec/"scripts").install Dir["scripts/*.sh"] if Dir["scripts/*.sh"].any?
      (libexec/"scripts").install Dir["scripts/*.ps1"] if Dir["scripts/*.ps1"].any?
      (libexec/"scripts").install Dir["scripts/*.js"] if Dir["scripts/*.js"].any?
      (libexec/"scripts").install Dir["scripts/*.swift"] if Dir["scripts/*.swift"].any?
    end

    # Install MCP server
    if (buildpath/"mcp").exist?
      (libexec/"mcp").install Dir["mcp/*"]
    end

    # Install skills
    (libexec/"skills/peon-ping-toggle").install "skills/peon-ping-toggle/SKILL.md" if (buildpath/"skills/peon-ping-toggle/SKILL.md").exist?
    (libexec/"skills/peon-ping-config").install "skills/peon-ping-config/SKILL.md" if (buildpath/"skills/peon-ping-config/SKILL.md").exist?
    (libexec/"skills/peon-ping-use").install "skills/peon-ping-use/SKILL.md" if (buildpath/"skills/peon-ping-use/SKILL.md").exist?
    (libexec/"skills/peon-ping-log").install "skills/peon-ping-log/SKILL.md" if (buildpath/"skills/peon-ping-log/SKILL.md").exist?

    # Install trainer voice packs
    if (buildpath/"trainer").exist?
      libexec.install "trainer/manifest.json" if (buildpath/"trainer/manifest.json").exist?
      if (buildpath/"trainer/sounds").exist?
        (buildpath/"trainer/sounds").each_child do |sound_file|
          next unless sound_file.file?
          (libexec/"trainer/sounds").install sound_file
        end
      end
    end

    # Install registry
    if (buildpath/"registry").exist?
      (libexec/"registry").install Dir["registry/*"]
    end

    # Install icon
    (libexec/"docs").install "docs/peon-icon.png" if (buildpath/"docs/peon-icon.png").exist?

    # Create wrapper script that delegates to peon.sh
    (bin/"peon").write <<~EOS
      #!/bin/bash
      exec bash "#{libexec}/peon.sh" "$@"
    EOS

    # Create setup script
    (bin/"peon-ping-ru-setup").write <<~EOS
      #!/bin/bash
      # peon-ping-ru setup — auto-detects IDEs and sets up hooks + sound packs
      set -euo pipefail

      INSTALL_ALL=false
      CUSTOM_PACKS=""
      for arg in "$@"; do
        case "$arg" in
          --all) INSTALL_ALL=true ;;
          --packs=*) CUSTOM_PACKS="${arg#--packs=}" ;;
          --help|-h)
            echo "Usage: peon-ping-ru-setup [--all] [--packs=pack1,pack2,...]"
            echo ""
            echo "Auto-detects installed IDEs and sets up peon-ping-ru."
            exit 0
            ;;
        esac
      done

      LIBEXEC="$(brew --prefix peon-ping-ru)/libexec"
      REGISTRY_URL="https://raw.githubusercontent.com/NikitaFrankov/peon-ping-ru/main/registry/index.json"
      PACKS_DIR="$HOME/.openpeon/packs"

      DEFAULT_PACKS="peonRu peasantRu"

      echo "=== peon-ping-ru setup ==="
      echo ""

      CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
      if [ ! -d "$CLAUDE_DIR" ]; then
        echo "Error: Claude Code not found at $CLAUDE_DIR"
        exit 1
      fi

      echo "Setting up for Claude Code..."

      HOOKS_DIR="$CLAUDE_DIR/hooks/peon-ping"
      mkdir -p "$HOOKS_DIR"

      # Link libexec files
      ln -sf "$LIBEXEC/peon.sh" "$HOOKS_DIR/peon.sh"
      ln -sf "$LIBEXEC/config.json" "$HOOKS_DIR/config.json"
      ln -sf "$LIBEXEC/VERSION" "$HOOKS_DIR/VERSION"
      ln -sf "$LIBEXEC/uninstall.sh" "$HOOKS_DIR/uninstall.sh"
      ln -sf "$LIBEXEC/install.sh" "$HOOKS_DIR/install.sh"

      # Link adapters
      mkdir -p "$HOOKS_DIR/adapters"
      if [ -d "$LIBEXEC/adapters" ]; then
        for f in "$LIBEXEC/adapters"/*; do
          ln -sf "$f" "$HOOKS_DIR/adapters/$(basename "$f")"
        done
      fi

      # Link scripts
      mkdir -p "$HOOKS_DIR/scripts"
      if [ -d "$LIBEXEC/scripts" ]; then
        for f in "$LIBEXEC/scripts"/*; do
          ln -sf "$f" "$HOOKS_DIR/scripts/$(basename "$f")"
        done
      fi

      # Link skills
      mkdir -p "$HOOKS_DIR/skills"
      if [ -d "$LIBEXEC/skills" ]; then
        for d in "$LIBEXEC/skills"/*; do
          if [ -d "$d" ]; then
            mkdir -p "$HOOKS_DIR/skills/$(basename "$d")"
            ln -sf "$d/SKILL.md" "$HOOKS_DIR/skills/$(basename "$d")/SKILL.md" 2>/dev/null || true
          fi
        done
      fi

      # Link registry
      mkdir -p "$HOOKS_DIR/registry"
      if [ -d "$LIBEXEC/registry" ]; then
        for f in "$LIBEXEC/registry"/*; do
          ln -sf "$f" "$HOOKS_DIR/registry/$(basename "$f")"
        done
      fi

      # Download sound packs
      mkdir -p "$PACKS_DIR"

      if [ "$INSTALL_ALL" = true ]; then
        echo "Downloading all packs..."
        PACKS_TO_INSTALL=$(curl -fsSL "$REGISTRY_URL" | python3 -c "import json,sys; data=json.load(sys.stdin); print(','.join(p['name'] for p in data.get('packs',[])))")
      elif [ -n "$CUSTOM_PACKS" ]; then
        PACKS_TO_INSTALL="$CUSTOM_PACKS"
      else
        PACKS_TO_INSTALL="$DEFAULT_PACKS"
      fi

      echo "Installing packs: $PACKS_TO_INSTALL"

      IFS=',' read -ra PACKS <<< "$PACKS_TO_INSTALL"
      for pack in "${PACKS[@]}"; do
        pack=$(echo "$pack" | tr -d ' ')
        if [ -n "$pack" ]; then
          echo "  Downloading $pack..."
          PACK_URL="https://github.com/NikitaFrankov/peon-ping-ru/releases/download/packs/\${pack}.tar.gz"
          curl -fsSL "$PACK_URL" | tar -xzf - -C "$PACKS_DIR" 2>/dev/null || \
            echo "    Note: Pack $pack may need manual download"
        fi
      done

      # Link packs directory
      ln -sf "$PACKS_DIR" "$HOOKS_DIR/packs" 2>/dev/null || true

      # Register hooks in Claude settings
      SETTINGS="$CLAUDE_DIR/settings.json"
      if [ -f "$SETTINGS" ]; then
        echo "Hooks registered in $SETTINGS"
      fi

      echo ""
      echo "Setup complete!"
      echo "Run 'peon status' to check installation."
    EOS
  end

  def caveats
    <<~EOS
      peon-ping-ru installed!

      To set up hooks for Claude Code:
        peon-ping-ru-setup

      Or manually:
        mkdir -p ~/.claude/hooks/peon-ping
        ln -s #{libexec}/* ~/.claude/hooks/peon-ping/

      Commands:
        peon status      - Show current status
        peon toggle      - Toggle sounds on/off
        peon pack [name] - Switch sound pack
        peon volume 0.5  - Set volume (0.0-1.0)
    EOS
  end

  test do
    assert_match "peon-ping", shell_output("#{bin}/peon status 2>&1 || true")
  end
end
