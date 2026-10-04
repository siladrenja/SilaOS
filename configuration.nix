{ config, lib, pkgs,userSettings, keybinds, ... }:

let
  browserClass = userSettings.apps.browser.class or userSettings.apps.browser.cmd;
in
{
  imports =
    [
    ];

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  nixpkgs.config.allowUnfree = true;

  services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 35;
      };
};

programs.steam = {
  enable = true;
};

programs.dconf.enable = true;

  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandlePowerKey = "hibernate";
      HandlePowerKeyLongPress = "poweroff";
    };
  };

  powerManagement = {
    enable = true;
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "10m";
  };

  security.polkit.enable= true;

  environment.variables = {
    GSK_RENDERER = "Vulkan";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zagreb";

  i18n.defaultLocale = "en_US.UTF-8";

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$all";
      success_symbol = "[->](bold green)";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      starship init fish | source
    '';
  };

  services.libinput.enable = true;

  users.users.matej = {
    name = "matej";
    home = "/home/matej";
    isNormalUser = true;
    extraGroups = ["wheel" "audio" "networkmanager" "plugdev" "dialout" "docker"];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    git-credential-manager
    lsd
    udiskie
    polkit_gnome
    breeze-hacked-cursor-theme
    xdg-utils
    efivar
    (python3.withPackages (python-pkgs: with python-pkgs; [
      pandas
      plotly
      matplotlib
    ]))
    efibootmgr
    pavucontrol
    tree
    inetutils
    killall
    gnome-control-center
    btop

    bluez
    bluez-tools

    nano
  ];

  hardware.firmware = with pkgs; [
    sof-firmware
  ];

  security.pam.services.hyprlock = {};

  services.gnome.gnome-keyring.enable = true;  

  programs.git = {
    enable = true;
    config = {
      credential.helper = "manager";
      credential.credentialStore = "secretservice";
    };
  };

  fonts = {
    enableDefaultPackages = true;
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

  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.evolution-data-server.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.firewall.enable = false;
}

