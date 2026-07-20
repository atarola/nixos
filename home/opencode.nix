{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  options.opencode.enable = lib.mkEnableOption "enables opencode";

  config = lib.mkIf config.opencode.enable {
    home.packages = with pkgs; [
      opencode
      poppler-utils
    ];

    services.local-code-context = {
      enable = true;
      autoStart = false;
      package = inputs.local-code-context.packages.${pkgs.stdenv.hostPlatform.system}.default;
      workspaces = [ "${config.home.homeDirectory}/code" ];
      repos = [ "${config.home.homeDirectory}/nixos" ];
    };

    xdg.configFile = {
      "opencode/agents/repo-notetaker.md" = {
        force = true;
        source = ./shared/agents/repo-notetaker.md;
      };

      "opencode/agents/personal-project-notetaker.md" = {
        force = true;
        source = ./shared/agents/personal-project-notetaker.md;
      };

      "opencode/instructions.md" = {
        force = true;
        source = ./shared/instructions.md;
      };

      "opencode/opencode.jsonc" = {
        force = true;
        source = ./opencode/opencode.jsonc;
      };

      "opencode/tui.json" = {
        force = true;
        source = ./opencode/tui.json;
      };

      "opencode/opencode-quota/quota-toast.json" = {
        force = true;
        source = ./opencode/opencode-quota/quota-toast.json;
      };
    };
  };
}
