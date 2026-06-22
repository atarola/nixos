{ config, pkgs, ... }:

{
    home.username = "atarola";
    home.homeDirectory = "/home/atarola";

    home.packages = with pkgs; [
        python3    
    ];

    programs.git = {
        enable = true;
        userName = "atarola";
        userEmail = "anthony.tarola@gmail.com";
        extraConfig = {
            init.defaultBranch = "main";
        };
    };

    programs.bash = {
        enable = true;
        enableCompletion = true;
        
        # TODO add your custom bashrc here
        bashrcExtra = ''
            export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
        '';

        # set some aliases, feel free to add more or remove some
        shellAliases = {
            urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
            urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
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
