{ config, pkgs, ... }:

{
  home.username = "atarola";
  home.homeDirectory = "/home/atarola";

  home.packages = with pkgs; [
    # utils
    btop
    ripgrep
    jq
    minipro
    tio

    # verilog
    iverilog
    verilator
    yosys
    nextpnr
    icestorm
    surfer

    # language stuff
    rustup
    python3
    uv
    cc65

    # formatters
    stylua
    nixfmt
    ruff

    # lsp servers
    pyright
    nixd
    asm-lsp
  ];

  services.ssh-agent.enable = true;

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      nvim-treesitter
      nvim-lspconfig
      conform-nvim
      lualine-nvim
      nvim-web-devicons
      nvim-tree-lua
      kanagawa-nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-asm_ca65";
        src = pkgs.fetchFromGitHub {
          owner = "maxbane";
          repo = "vim-asm_ca65";
          rev = "master";
          sha256 = "sha256-9SoYDbGlTRY9yEC0SQCwNx+gohK4JG8MRB46ekV0+6c=";
        };
      })
    ];

    initLua = ''
      vim.g.mapleader = " "

      vim.opt.number = true
      vim.opt.expandtab = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.softtabstop = 2

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

      require('conform').setup({
          formatters_by_ft = {
              python = { "ruff_format" },
              rust = { "rustfmt" },
              lua = { "stylua" },
              nix = { "nixfmt" },
          },
          format_on_save = {
              timeout_ms = 500,
              lsp_fallback = true,
          },
      });

      vim.lsp.config('pyright', {})
      vim.lsp.config('nixd', {})
      vim.lsp.config('asm_lsp', {
          filetypes = { "asm", "s" },
      })

      vim.lsp.config('rust_analyzer', {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })

      vim.lsp.enable({'pyright', 'nixd', 'asm_lsp', 'rust_analyzer'})

      -- keybindings, these only activate when lsp is attached
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover docs' })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show error' })


      require('lualine').setup({
        options = {
          theme = 'auto',
          component_separators = { left = '\u{e0b1}', right = '\u{e0b3}'},
          section_separators = { left = '\u{e0b0}', right = '\u{e0b2}'},
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'},
        },
      })

      require('kanagawa').setup({
        theme = 'dragon',  -- wave, dragon, lotus
        background = {
          dark = "dragon"
        }
      })
      vim.cmd("colorscheme kanagawa")

      require('nvim-tree').setup({})

      -- toggle with ctrl+n
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
      -- focus tree
      vim.keymap.set('n', '<leader>e', ':NvimTreeFocus<CR>', { desc = 'Focus file tree' })
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "atarola";
      user.email = "anthony.tarola@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

      SSH_ENV="$HOME/.ssh/agent-env"

      if [ -f "$SSH_ENV" ]; then
          source "$SSH_ENV" > /dev/null
      fi

      if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
          ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
          chmod 600 "$SSH_ENV"
          source "$SSH_ENV" > /dev/null
      fi
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";

      # rebuild and switch in one go from wherever you are
      nixswitch = "sudo nixos-rebuild switch --flake ~/nixos#nixos";

      # update all flake inputs (nixpkgs, home-manager, etc.)
      nixup = "sudo nix flake update ~/nixos";

      # edit config quickly
      nixconf = "vim ~/nixos/configuration.nix";
      nixhome = "vim ~/nixos/home.nix";

      # garbage collect old generations
      nixgc = "sudo nix-collect-garbage -d";

      # list generations
      nixgen = "sudo nix-env --list-generations";
    };
  };

  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
    };
    extraConfig = ''
      set softtabstop=4
    '';
  };

  home.stateVersion = "26.05";
}
