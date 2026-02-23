# NikitaFrankov Homebrew Tap

Homebrew tap for [peon-ping-ru](https://github.com/NikitaFrankov/peon-ping-ru) — Russian voice pack for Claude Code hooks.

## Installation

**Шаг 1: Установка через Homebrew**

```bash
# Вариант A: Двумя командами
brew tap NikitaFrankov/tap
brew install peon-ping-ru

# Вариант B: Одной командой
brew install NikitaFrankov/tap/peon-ping-ru
```

**Шаг 2: Настройка хуков (ОБЯЗАТЕЛЬНО)**

После установки нужно запустить setup, чтобы создать ссылки в директории Claude:

```bash
peon-ping-ru-setup
```

**Проверка:**

```bash
peon status
```

Должно показать: `peon-ping: active`

## What is peon-ping-ru?

peon-ping-ru is a Russian localization of [peon-ping](https://github.com/PeonPing/peon-ping) — sound effects and desktop notifications for AI coding assistants (Claude Code, Cursor, Windsurf, etc.).

It plays Warcraft III Peon voice lines (in Russian) when:
- Session starts ("Work complete!")
- Task completes ("Ready to work!")
- Input required ("Yes?"
- Error occurs

## Commands

```bash
peon status          # Show current status and active pack
peon toggle          # Toggle sounds on/off
peon pause           # Pause sounds
peon resume          # Resume sounds
peon pack [name]     # Switch sound pack (or cycle to next)
peon packs           # List installed packs
peon volume 0.5      # Set volume (0.0 - 1.0)
peon notifications   # Configure desktop notifications
peon trainer on/off  # Enable/disable workout reminders
peon help            # Show all commands
```

## Available Sound Packs

- `peonRu` — Russian Peon voices (default)
- `peasantRu` — Russian Peasant voices

## Manual Setup

If you prefer manual setup:

```bash
# Create hooks directory
mkdir -p ~/.claude/hooks/peon-ping

# Link files from Homebrew installation
ln -s $(brew --prefix peon-ping-ru)/libexec/* ~/.claude/hooks/peon-ping/
```

## Updating

```bash
brew update
brew upgrade peon-ping-ru
```

## Uninstalling

```bash
brew uninstall peon-ping-ru
brew untap NikitaFrankov/tap
```

## Links

- [peon-ping-ru repository](https://github.com/NikitaFrankov/peon-ping-ru)
- [Original peon-ping](https://github.com/PeonPing/peon-ping)
- [PeonPing organization](https://github.com/PeonPing)
