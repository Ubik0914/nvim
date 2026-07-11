#!/usr/bin/env bash
#
# Ubuntu 向け Neovim 環境セットアップスクリプト
#
# 実行方法:
#   curl -fsSL https://raw.githubusercontent.com/Ubik0914/nvim/main/setup.sh | bash
#
# 内容:
#   1. apt で依存ツールを導入 (git / curl / build-essential / unzip / ripgrep / fd-find / fzf)
#   2. Neovim 最新 stable を GitHub releases から /opt/nvim に導入 (0.10+ が既にあればスキップ)
#   3. Node.js 18+ を導入 (mason の LSP 実行に必要。既にあればスキップ)
#   4. 既存の ~/.config/nvim を退避してからこのリポジトリを clone
#   5. lazy-lock.json どおりにプラグインを一括導入

set -euo pipefail

REPO_URL="https://github.com/Ubik0914/nvim.git"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
LOCAL_BIN="$HOME/.local/bin"
NVIM_OPT_DIR="/opt/nvim"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
err()  { printf '\033[1;31mERROR:\033[0m %s\n' "$1" >&2; }

if ! command -v apt-get >/dev/null 2>&1; then
  err "apt-get が見つかりません。このスクリプトは Ubuntu を対象としています。"
  exit 1
fi

SUDO="sudo"
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
fi

info "apt パッケージを導入します"
$SUDO apt-get update -y
$SUDO apt-get install -y \
  git curl ca-certificates build-essential unzip ripgrep fd-find fzf

mkdir -p "$LOCAL_BIN"

# Ubuntu では fd-find のバイナリ名が fdfind のため、fd 名で呼べるようにする
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
  info "fd -> fdfind の symlink を作成しました"
fi

need_nvim=1
if command -v nvim >/dev/null 2>&1; then
  ver="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  major="${ver%%.*}"
  minor="${ver#*.}"
  if [ "$major" -gt 0 ] || [ "$minor" -ge 10 ]; then
    need_nvim=0
    info "nvim v${ver} が導入済みのためスキップします"
  fi
fi

if [ "$need_nvim" -eq 1 ]; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  asset="nvim-linux-x86_64.tar.gz" ;;
    aarch64) asset="nvim-linux-arm64.tar.gz" ;;
    *)
      err "未対応のアーキテクチャです: $arch"
      exit 1
      ;;
  esac

  info "Neovim 最新 stable を導入します (${asset})"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  curl -fL "https://github.com/neovim/neovim/releases/latest/download/${asset}" \
    -o "$tmp/nvim.tar.gz"
  $SUDO rm -rf "$NVIM_OPT_DIR"
  $SUDO mkdir -p "$NVIM_OPT_DIR"
  $SUDO tar -xzf "$tmp/nvim.tar.gz" -C "$NVIM_OPT_DIR" --strip-components=1
  ln -sf "$NVIM_OPT_DIR/bin/nvim" "$LOCAL_BIN/nvim"
fi

export PATH="$LOCAL_BIN:$PATH"

need_node=1
if command -v node >/dev/null 2>&1; then
  node_major="$(node -v | sed 's/^v//' | cut -d. -f1)"
  if [ "$node_major" -ge 18 ]; then
    need_node=0
    info "Node.js $(node -v) が導入済みのためスキップします"
  fi
fi

if [ "$need_node" -eq 1 ]; then
  info "Node.js LTS を導入します (NodeSource)"
  curl -fsSL https://deb.nodesource.com/setup_lts.x | $SUDO -E bash -
  $SUDO apt-get install -y nodejs
fi

if [ -e "$NVIM_CONFIG_DIR" ]; then
  backup="${NVIM_CONFIG_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  info "既存の設定を退避します: $backup"
  mv "$NVIM_CONFIG_DIR" "$backup"
fi

info "設定リポジトリを clone します"
git clone "$REPO_URL" "$NVIM_CONFIG_DIR"

info "プラグインを一括導入します (lazy-lock.json 準拠)"
nvim --headless "+Lazy! restore" +qa

info "セットアップ完了"
echo ""
echo "次を確認してください:"
echo "  - ~/.local/bin が PATH に含まれること (未設定なら ~/.bashrc に追記):"
echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "  - 初回の nvim 起動時に mason が LSP サーバーを自動導入します"
