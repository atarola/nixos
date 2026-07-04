{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    local-code-context = {
      url = "github:atarola/local-code-context";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      nixvim,
      ...
    }@inputs:
    let
      mkMachine = name: let machine = import ./machines/${name}.nix { inherit inputs nixpkgs nixos-wsl home-manager nixvim; }; in nixpkgs.lib.nixosSystem {
        system = machine.system;
        modules = machine.modules;
      };
    in {
      nixosConfigurations = {
        speedy = mkMachine "speedy";
      };
    };
}
