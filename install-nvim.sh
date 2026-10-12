#!/usr/bin/env bash
set -eu

download="$(mktemp)"
target="$(sudo mktemp /usr/bin/.nvim.XXXXXX)"
trap 'rm -f "$download"; sudo rm -f "$target"' EXIT

curl -fL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage -o "$download"
sudo install -m 755 "$download" "$target"
sudo mv -f "$target" /usr/bin/nvim

nvim --version
