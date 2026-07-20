{ lib, pkgs, config, ... }:

{
  options.ollama.enable = lib.mkEnableOption "enables ollama";

  config = lib.mkIf config.ollama.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
