{ pkgs, lib, config, ... }:

{
  options.development.enable = lib.mkEnableOption "enables development";

  config = lib.mkIf config.development.enable {
    home.packages = with pkgs; [
      minipro
      iverilog
      verilator
      yosys
      nextpnr
      icestorm
      surfer
      rustup
      python3
      uv
      cc65
    ];
  };
}
