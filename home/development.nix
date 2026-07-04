{ pkgs, ... }:

{
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
}
