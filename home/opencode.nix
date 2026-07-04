{ pkgs, lib, config, ... }:

{
  options.opencode.enable = lib.mkEnableOption "enables opencode";

  config = lib.mkIf config.opencode.enable {
    home.packages = with pkgs; [
      opencode
    ];

    services.local-code-context = {
      enable = true;

      workspaces = [
        "/home/atarola/code"
      ];

      db = "/home/atarola/.local/share/local-code-context/codebase_index";

      autoStart = false;
    };

    xdg.configFile = {
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
                  "nix",
                  "run",
                  "/home/atarola/code/local-code-context#mcp",
                  "--",
                  "--db",
                  "/home/atarola/.local/share/local-code-context/codebase_index"
                ]
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
