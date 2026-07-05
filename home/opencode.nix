{ inputs, pkgs, lib, config, ... }:

let
  localCodeContextMcp = "${config.services.local-code-context.package}/bin/code-context-mcp";
  localCodeContextDb = config.services.local-code-context.db;
in
{
  options.opencode.enable = lib.mkEnableOption "enables opencode";

  config = lib.mkIf config.opencode.enable {
    services.local-code-context.package = inputs.local-code-context.packages.${pkgs.stdenv.hostPlatform.system}.default;

    home.packages = with pkgs; [
      opencode
    ];

    services.local-code-context.workspaces = [
      "${config.home.homeDirectory}/code"
    ];

    services.local-code-context.repos = [
      "${config.home.homeDirectory}/nixos"
    ];

    services.local-code-context = {
      enable = true;

      autoStart = false;
    };

    xdg.configFile = {
      "opencode/agents/planning-notetaker.md" = {
        force = true;
        source = ./opencode/agents/planning-notetaker.md;
      };

      "opencode/agents/repo-notetaker.md" = {
        force = true;
        source = ./opencode/agents/repo-notetaker.md;
      };

      "opencode/skills/planning/SKILL.md" = {
        force = true;
        source = ./opencode/skills/planning.md;
      };

      "opencode/opencode.jsonc" = {
        force = true;
        text = ''
          {
            "$schema": "https://opencode.ai/config.json",
            "plugin": ["@slkiser/opencode-quota"],
            "mcp": {
              "local-code-context": {
                "type": "local",
                "command": [
                  "${localCodeContextMcp}",
                  "--db",
                  "${localCodeContextDb}"
                ]
              }
            },
            "permission": {
              "external_directory": {
                "~/.config/opencode/**": "allow",
                "~/notes/**": "allow"
              }
            }
          }
        '';
      };

      "opencode/tui.json" = {
        force = true;
        text = ''
          {
            "$schema": "https://opencode.ai/tui.json",
            "plugin": ["@slkiser/opencode-quota"]
          }
        '';
      };

      "opencode/opencode-quota/quota-toast.json" = {
        force = true;
        text = ''
          {
            "enableToast": false,
            "tuiSidebarPanel": {
              "enabled": true
            }
          }
        '';
      };
    };
  };
}
