#!/usr/bin/env bash
set -eu

asset_arch() {
  case "$1" in
    x86_64 | amd64) printf x86_64 ;;
    aarch64 | arm64) printf arm64 ;;
    *) printf 'Unsupported architecture: %s\n' "$1" >&2; return 1 ;;
  esac
}

test "$(asset_arch x86_64)" = x86_64
test "$(asset_arch aarch64)" = arm64
arch="$(asset_arch "$(uname -m)")"
download="$(mktemp)"
target="$(sudo mktemp /usr/bin/.nvim.XXXXXX)"
trap 'rm -f "$download"; sudo rm -f "$target"' EXIT

curl -fL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.appimage" -o "$download"
sudo install -m 755 "$download" "$target"
sudo mv -f "$target" /usr/bin/nvim

nvim --version
