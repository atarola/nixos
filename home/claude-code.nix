{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.claude-code.enable = lib.mkEnableOption "enables claude-code";

  config = lib.mkIf config.claude-code.enable {
    home.packages = [ pkgs.claude-code ];

    home.file = {
      ".claude/settings.json" = {
        force = true;
        text = lib.generators.toJSON { } {
          permissions = {
            allow = [
              "Edit(/home/${config.home.username}/notes/*)"
              "Write(/home/${config.home.username}/notes/*)"
            ];
          };
          mcpServers = {
            local-code-context = {
              command = "/etc/profiles/per-user/${config.home.username}/bin/code-context-mcp";
              args = [ "--db" config.services.local-code-context.db ];
            };
          };
          statusLine = {
            type = "command";
            command = "/home/${config.home.username}/.claude/statusline.sh";
            padding = 2;
          };
        };
      };

      ".claude/CLAUDE.md" = {
        force = true;
        source = ./shared/instructions.md;
      };

      ".claude/agents/repo-notetaker.md" = {
        force = true;
        source = ./shared/agents/repo-notetaker.md;
      };

      ".claude/agents/personal-project-notetaker.md" = {
        force = true;
        source = ./shared/agents/personal-project-notetaker.md;
      };

      ".claude/statusline.sh" = {
        force = true;
        executable = true;
        source = ./claude-code/statusline.sh;
      };
    };
  };
}
