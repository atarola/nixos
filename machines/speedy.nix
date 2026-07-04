{ inputs, nixpkgs, nixos-wsl, home-manager, nixvim }:

{
  system = "x86_64-linux";

  modules = [
    nixos-wsl.nixosModules.default
    ../configuration.nix
    {
      networking.hostName = "speedy";
    }
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.atarola = {
        imports = [ ../home.nix ];
        toolchains.enable = true;
        toolchains.verilog.enable = true;
        toolchains.rust.enable = true;
        toolchains.python.enable = true;
        toolchains.cc65.enable = true;
        shell.enable = true;
        nvim.enable = true;
        opencode.enable = true;
      };
      home-manager.sharedModules = [
        nixvim.homeModules.nixvim
      ];
    }
  ];
}
