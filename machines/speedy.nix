{ inputs, nixpkgs, nixos-wsl, home-manager, nixvim }:

{
  system = "x86_64-linux";

  modules = [
    nixos-wsl.nixosModules.default
    ../packages.nix
    ({ lib, pkgs, ... }:
    {
      networking.hostName = "speedy";

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

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      system.stateVersion = "26.05";
    })
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
