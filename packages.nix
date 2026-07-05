{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    kmod
  ];
}
