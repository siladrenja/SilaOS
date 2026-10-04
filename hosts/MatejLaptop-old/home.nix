{ config, pkgs, ... }:

{
  _module.args.monitorLUT = [
    "HDMI-A-1"
    "DP-1"
    "eDP-1"
  ];
}
