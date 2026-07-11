# nvim

Neovim configuration (lazy.nvim + mason)

## Setup (Ubuntu)

```bash
curl -fsSL https://raw.githubusercontent.com/Ubik0914/nvim/main/setup.sh | bash
```

setup.sh が行うこと:

- apt で依存ツールを導入
  - git
  - curl
  - build-essential
  - unzip
  - ripgrep
  - fd-find
  - fzf
- Neovim 最新 stable を `/opt/nvim` に導入（0.10+ が既にあればスキップ）
- Node.js 18+ を導入（既にあればスキップ）
- 既存の `~/.config/nvim` を `~/.config/nvim.bak.日時` へ退避してから clone
- `lazy-lock.json` どおりにプラグインを一括導入

LSP サーバーは初回の nvim 起動時に mason が自動導入する。

## 手動セットアップ（macOS など）

```bash
git clone https://github.com/Ubik0914/nvim.git ~/.config/nvim
nvim
```

前提ツール:

- git
- nvim 0.10+
- ripgrep
- fd
- fzf
- Node.js 18+
- C コンパイラ（treesitter・telescope-fzf-native のビルド用）
