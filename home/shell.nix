{ pkgs, lib, config, osConfig, ... }:

{
  options.shell.enable = lib.mkEnableOption "enables shell";

  config = lib.mkIf config.shell.enable {
    home.packages = with pkgs; [
      usbutils
      btop
      ripgrep
      jq
      tio
      direnv
    ];

    services.ssh-agent.enable = true;

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
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

        eval "$(direnv hook bash)"
      '';

      shellAliases = {
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
        urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";

        # rebuild and switch in one go from wherever you are
        nixswitch = "sudo nixos-rebuild switch --flake ~/nixos#${osConfig.networking.hostName}";

        # update all flake inputs (nixpkgs, home-manager, etc.)
        nixup = "sudo nix flake update ~/nixos";

        # edit config quickly
        nixconf = "vim ~/nixos/configuration.nix";
        nixhome = "vim ~/nixos/home.nix";
        nixmachine = "vim ~/nixos/machines/speedy.nix";

        # garbage collect old generations
        nixgc = "sudo nix-collect-garbage -d";

        # list generations
        nixgen = "sudo nix-env --list-generations";
      };
    };
  };
}
