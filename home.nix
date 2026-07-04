{
  inputs,
  ...
}:

{
  imports = [
    inputs.local-code-context.homeManagerModules.default
    ./home/development.nix
    ./home/shell.nix
    ./home/nvim.nix
    ./home/opencode.nix
  ];

  home.username = "atarola";
  home.homeDirectory = "/home/atarola";

  home.stateVersion = "26.05";
}
