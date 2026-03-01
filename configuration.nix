{ config, lib, pkgs, ... }:
let
  home-manager= builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
let
  preferences = {
    defaultWebPage = "https://google.com";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = "source (/etc/profiles/per-user/matej/bin/starship init fish)";
  };

  users.users.matej = {
    name = "matej";
    home = "/home/matej";
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.fish;
  };

  users.users.media = {
    name = "media";
    home = "/home/media";
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.fish;
  };

  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
    home = "/var/lib/greetd";
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  users.groups.greeter = {};

  home-manager.useUserPackages= true;
  home-manager.useGlobalPkgs= true;
  home-manager.backupFileExtension= "backup";

  home-manager.users.matej= import ./matej.nix;
  home-manager.users.media = import ./media.nix;

  security.polkit.enable= true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

 # boot.kernelPackages = pkgs.linuxPackages_latest;
boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "MatejLaptop"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Zagreb";


  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    lsd
    (pkgs.callPackage ./pkgs/swayhide.nix{})
    cage
    udiskie
    udisks2
    polkit_gnome
    libsecret
  ];


   fonts = {
  enableDefaultFonts = true;
  packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
  ];
};


  systemd.user.services.polkit-gnome-authentication-agent = {
  description = "Polkit GNOME Authentication Agent";
  wantedBy = [ "graphical-session.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Restart = "always";
  };
};


  services.gnome.gnome-keyring.enable = true;

  services.openssh.enable = true;

  programs.regreet.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

services.greetd = {
  enable = true;
  vt = 1;
  settings = {
    default_session = {
#      command = "${pkgs.cage}/bin/cage -s ${pkgs.greetd.regreet}/bin/regreet";
#       command = "${pkgs.greetd.regreet}/bin/regreet";
      user = "greeter";
    };

    user_sessions = {
      matej = {
        command = "sway";
      };
      media = {
        command = "cage -- kodi-standalone";
      };
    };
  };
};
services.greetd.settings.environment = {
  XDG_DATA_DIRS = "/run/current-system/sw/share";
  XDG_CONFIG_DIRS = "/etc/xdg";
};

environment.variables = {GSK_RENDERER="ngl";};

security.pam.services.greetd.enableGnomeKeyring = true;



  system.stateVersion = "25.05"; # Did you read the comment?
  
}
