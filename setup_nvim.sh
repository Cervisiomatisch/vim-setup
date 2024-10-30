#!/bin/bash

# Zielverzeichnisse
CONFIG_DIR="$HOME/.config/nvim"
PLUGGED_DIR="$CONFIG_DIR/plugged"
AUTOLOAD_DIR="$CONFIG_DIR/autoload"
COLORS_DIR="$CONFIG_DIR/colors"

# Schritt 1: Prüfe, ob Neovim installiert ist
if ! command -v nvim &> /dev/null; then
    echo "Neovim wird installiert..."
    brew install neovim
else
    echo "Neovim ist bereits installiert."
    read -p "Möchtest du eine saubere Installation? (j/n): " clean_install
    if [[ $clean_install == "j" ]]; then
        echo "Lösche bestehende Neovim-Konfiguration..."
        rm -rf "$CONFIG_DIR"
        echo "Existierende Konfiguration gelöscht. Erstelle eine neue..."
    else
        echo "Bestehende Konfiguration wird ergänzt."
    fi
fi

# Schritt 2: Vim-Plug Plugin-Manager installieren
echo "Vim-Plug wird installiert..."
curl -fLo "${AUTOLOAD_DIR}/plug.vim" --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Schritt 3: Erstelle Verzeichnisstruktur
echo "Erstelle Verzeichnisstruktur für Neovim Konfiguration..."
mkdir -p "$CONFIG_DIR"/{after/plugin,lua} "$PLUGGED_DIR" "$COLORS_DIR"

# Schritt 4: Erstellen von init.vim mit Plugin-Konfiguration
echo "Erstelle init.vim mit vim-plug Plugin-Konfiguration..."
cat <<EOF > "$CONFIG_DIR/init.vim"
" Plugin-Manager Setup
call plug#begin('~/.config/nvim/plugged')

" Plenary als Abhängigkeit
Plug 'nvim-lua/plenary.nvim'

" Dateiexplorer
Plug 'kyazdani42/nvim-tree.lua'

" Syntax-Highlighting und Autocompletion
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

" LSP-Server und Unterstützung für Python, C, C++, Java
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Vorschau beim Suchen und Ersetzen
Plug 'nvim-pack/nvim-spectre'

" Statuszeile und Farbschema
Plug 'nvim-lualine/lualine.nvim'
Plug 'gruvbox-community/gruvbox'

call plug#end()

" Grundeinstellungen
syntax enable
set background=dark
colorscheme gruvbox

" Dateiexplorer und Tastenkürzel
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>f :lua require('spectre').open()<CR>
EOF

# Schritt 5: Installiere Plugins
echo "Installiere Plugins mit Neovim..."
nvim +PlugInstall +qall

# Schritt 6: Plugins konfigurieren
echo "Erstelle Plugin-Konfigurationen..."

# nvim-tree Konfiguration
cat <<EOF > "$CONFIG_DIR/after/plugin/nvim-tree.rc.lua"
require('nvim-tree').setup {
  view = {
    width = 30,
    side = 'left',
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        folder = true,
        file = true,
        git = true,
      }
    }
  }
}
EOF

# Treesitter Konfiguration
cat <<EOF > "$CONFIG_DIR/after/plugin/treesitter.rc.lua"
require('nvim-treesitter.configs').setup {
    ensure_installed = {"python", "c", "cpp", "java"},
    highlight = { enable = true },
    indent = { enable = true }
}
EOF

# LSP und Mason Konfiguration
cat <<EOF > "$CONFIG_DIR/after/plugin/lsp-installer.lua"
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "clangd", "jdtls" }
})

local lspconfig = require'lspconfig'

lspconfig.pyright.setup{}
lspconfig.clangd.setup{}
lspconfig.jdtls.setup{}
EOF

# nvim-cmp Konfiguration
cat <<EOF > "$CONFIG_DIR/after/plugin/cmp.rc.lua"
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  })
})
EOF

# Spectre Konfiguration
cat <<EOF > "$CONFIG_DIR/after/plugin/spectre.rc.lua"
require('spectre').setup()
EOF

# lualine Konfiguration
cat <<EOF > "$CONFIG_DIR/after/plugin/lualine.rc.lua"
require('lualine').setup {
  options = { theme = 'gruvbox' }
}
EOF

# Farbschema und Farben konfigurieren
echo "Farbeinstellung wird angewendet..."
cat <<EOF > "$CONFIG_DIR/colorscheme.vim"
syntax enable
colorscheme gruvbox
set background=dark
EOF

# Schritt 7: Tastenkürzel konfigurieren
cat <<EOF > "$CONFIG_DIR/maps.vim"
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>f :lua require('spectre').open()<CR>
EOF

echo "Neovim-Setup abgeschlossen! Öffne Neovim und genieße die Konfiguration."