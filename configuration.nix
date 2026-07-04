{
  config,
  lib,
  pkgs,
  ...
}:

{
  wsl.enable = true;
  wsl.defaultUser = "atarola";
  wsl.useWindowsDriver = true;

  hardware.nvidia-container-toolkit = {
    enable = true;
    suppressNvidiaDriverAssertion = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      glibc
    ];
  };

  environment.sessionVariables = {
    NIX_LD_LIBRARY_PATH = lib.mkForce "/usr/lib/wsl/lib:/run/current-system/sw/share/nix-ld/lib";
  };

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
    kmod
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
