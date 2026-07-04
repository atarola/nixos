{ pkgs, lib, config, ... }:

{
  options.nvim.enable = lib.mkEnableOption "enables nvim";

  config = lib.mkIf config.nvim.enable {
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
              settings = {
                checkOnSave = true;
                check.command = "clippy";
              };
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

    home.packages = with pkgs; [
      stylua
      nixfmt
      ruff
      pyright
      nixd
      asm-lsp
    ];
  };
}
