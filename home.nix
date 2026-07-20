{
  inputs,
  ...
}:

{
  imports = [
    inputs.local-code-context.homeManagerModules.default
    ./home/toolchains.nix
    ./home/shell.nix
    ./home/nvim.nix
    ./home/opencode.nix
    ./home/claude-code.nix
  ];

  home.username = "atarola";
  home.homeDirectory = "/home/atarola";

  home.stateVersion = "26.05";
}
