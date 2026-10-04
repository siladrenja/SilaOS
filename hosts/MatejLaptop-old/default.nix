{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./disko.nix];

  networking.hostName = "MatejLaptop-old";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
    ];

    loader = {
      timeout = 20;
      systemd-boot = {
        enable = true;
      };
    };

    plymouth.enable = true;
    
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "i965";
  };
  
  virtualisation.docker.enable = true;

  hardware.bluetooth.enable = true;

  system.stateVersion = "26.05";
}
