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
      poppler-utils
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
            "instructions": ["${config.home.homeDirectory}/.config/opencode/instructions.md"],
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

      "opencode/instructions.md" = {
        force = true;
        text = ''
          # Global Guidelines

          ## Core Philosophy
          * **Passive Default**: Default strictly to research, review, and recommendations. Never implement, refactor, or edit code unless the user explicitly asks for implementation.
          * **Explicit Approval**: Report findings and proposed plans first. Wait for explicit user approval before modifying any files.
          * **Control**: Keep the user in the driver's seat. If intent or scope is unclear, ask one short, direct question instead of guessing.

          ## Interaction Guidelines
          * Always read relevant files completely before proposing changes.
          * Do not apologize or use conversational filler. Be direct and factual.
          * Provide moderate explanations with context, but stay highly concise.
          * Do not run git commands or create GitHub PRs. The user handles repository state.
          * Do not use destructive commands or revert unexpected worktree changes without permission.

          ## Code Reviews
          * Identify bugs, architectural flaws, and performance issues first.
          * Do not suggest or write fixes unless explicitly asked.
          * Check thoroughly for dead code, including unused imports, variables, and functions.
          * Flag any structural inconsistencies between source code and tests.

          ## Editing Rules
          * Prefer the smallest correct change that fulfills the request.
          * Preserve existing user work exactly as written.
          * Do not refactor, improve, or clean up code beyond the exact scope requested.
          * Do not add comments, docstrings, or type annotations to unchanged code.
          * If a task is implemented, run or verify with the smallest relevant unit check before declaring success.
          * If blocked, state the blocker plainly and ask one short question.

          ## Character Encoding
          * Use only ASCII characters in all project files.
          * Do not use Unicode characters in project files; use plain ASCII punctuation only.
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
