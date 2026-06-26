{ config, pkgs, ... }:

{
  home.username = "atarola";
  home.homeDirectory = "/home/atarola";

  home.packages = with pkgs; [
    # utils
    usbutils
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

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.kanagawa = {
      enable = true;
      settings = {
        theme = "dragon";
        background.dark = "dragon";
      };
    };

    opts = {
      number = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
    };

    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Move to left window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Move to right window";
      }
      {
        mode = "n";
        key = "gd";
        action.__raw = "vim.lsp.buf.definition";
        options.desc = "Go to definition";
      }
      {
        mode = "n";
        key = "K";
        action.__raw = "vim.lsp.buf.hover";
        options.desc = "Hover docs";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action.__raw = "vim.lsp.buf.rename";
        options.desc = "Rename";
      }
      {
        mode = "n";
        key = "<leader>ca";
        action.__raw = "vim.lsp.buf.code_action";
        options.desc = "Code action";
      }
      {
        mode = "n";
        key = "<leader>e";
        action.__raw = "vim.diagnostic.open_float";
        options.desc = "Show error";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>Bdelete<cr>";
      }
      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd>BufferLineCycleNext<cr>";
      }
      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>BufferLinePrev<cr>";
      }
    ];

    plugins = {
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Telescope find files";
          };
          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Telescope live grep";
          };
          "<leader>fb" = {
            action = "buffers";
            options.desc = "Telescope buffers";
          };
          "<leader>fh" = {
            action = "help_tags";
            options.desc = "Telescope help tags";
          };
        };
      };

      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.passthru.builtGrammars; [
          asm
          rust
          python
          nix
        ];
      };

      lsp = {
        enable = true;
        servers = {
          pyright.enable = true;
          nixd.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
            settings.checkOnSave.command = "clippy";
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            python = [ "ruff_format" ];
            rust = [ "rustfmt" ];
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
        };
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "seoul256";
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              "branch"
              "diff"
              "diagnostics"
            ];
            lualine_c = [ "filename" ];
            lualine_x = [
              "encoding"
              "filetype"
            ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
        };
      };

      which-key = {
        enable = true;
        settings.delay = 500;
      };

      gitsigns.enable = true;

      web-devicons.enable = true;

      bufferline = {
        enable = true;
        settings.options = {
          close_command = "Bdelete! %d";
          right_mouse_command = "Bdelete! %d";
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      bufdelete-nvim
      nvim-web-devicons
    ];

    # asm-lsp with custom root_dir, and the asm treesitter autocmd
    extraConfigLua = ''
      vim.lsp.config('asm_lsp', {
        filetypes = { "asm", "s" },
        root_dir = function(fname)
          return vim.fs.dirname(vim.fs.find('.asm-lsp.toml', { path = fname, upward = true })[1])
        end,
      })

      vim.lsp.enable({'asm_lsp'})

      vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
        pattern = { "*.s", "*.asm" },
        callback = function()
          vim.treesitter.start(0, "asm")
        end,
      })
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

  home.stateVersion = "26.05";
}
