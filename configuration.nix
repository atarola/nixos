{
  config,
  lib,
  pkgs,
  ...
}:

{
  wsl.enable = true;
  wsl.defaultUser = "atarola";

  users.users.atarola = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "dialout"
    ];
    shell = pkgs.bash;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.anonymice
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "26.05";
}
