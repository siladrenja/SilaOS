{ config, lib, pkgs, ... }:
let
    home-manager= builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
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

  programs.fish = {
    enable = true;
    interactiveShellInit = "source (/etc/profiles/per-user/matej/bin/starship init fish --print-full-init | psub)";
  };

  users.users.matej = {
    name = "matej";
    home = "/home/matej";
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.fish;
  };

  home-manager.useUserPackages= true;
  home-manager.useGlobalPkgs= true;
  home-manager.backupFileExtension= "backup";

  home-manager.users.matej= import ./matej.nix;

  security.polkit.enable= true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "MatejLaptop"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Zagreb";

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    lsd
    (pkgs.callPackage ./pkgs/swayhide.nix{})
  ];

 services.gnome.gnome-keyring.enable = true;

  services.openssh.enable = true;

  services.displayManager.ly.enable= true;
  
  system.stateVersion = "25.05"; # Did you read the comment?
  
}
