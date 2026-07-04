{ pkgs, lib, config, ... }:

{
  options.toolchains = {
    enable = lib.mkEnableOption "enables toolchains";

    verilog.enable = lib.mkEnableOption "enables verilog tools";
    rust.enable = lib.mkEnableOption "enables rust tools";
    python.enable = lib.mkEnableOption "enables python tools";
    cc65.enable = lib.mkEnableOption "enables cc65 tools";
  };

  config = lib.mkIf config.toolchains.enable {
    home.packages =
      lib.optionals config.toolchains.verilog.enable (with pkgs; [
        iverilog
        verilator
        yosys
        nextpnr
        icestorm
        surfer
      ])
      ++ lib.optionals config.toolchains.rust.enable (with pkgs; [
        rustup
      ])
      ++ lib.optionals config.toolchains.python.enable (with pkgs; [
        python3
        uv
      ])
      ++ lib.optionals config.toolchains.cc65.enable (with pkgs; [
        minipro
        cc65
      ]);
  };
}
