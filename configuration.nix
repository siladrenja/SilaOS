{ config, pkgs, ... }:

let preferences = {
    defaultWebPage = "https://google.com";
    backgroundPath = "/run/current-system/sw/share/backgrounds/nixos-logo.png";
}
in
{
    nixpkgs.config.allowUnfree = true;

    networking.firewall = {
    enable = false;
  };

  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};



  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "never";
      SearchBar = "unified";
      ExtensionSettings = {
        "*".installation_mode = "blocked"; # block all except listed
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "notabs@adsum" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/adsum-notabs/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
  # Tell Firefox to use Wayland natively
  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.steam = {
    enable = true;

    # Optional: open firewall ports for Steam features
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };


  environment.systemPackages = with pkgs; [
    sway
    wl-clipboard
    swaylock
    swayidle
    swaybg
    foot
    dmenu

    gcc
    cmake
    cmake

    python38
    python39
    python310
    python3

    (
      pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnetCorePackages.sdk_6_0
        pkgs.dotnetCorePackages.sdk_7_0
        pkgs.dotnetCorePackages.sdk_8_0
        pkgs.dotnetCorePackages.sdk_9_0
      ]
    )

    openjdk

    gradle
    maven

    dotnet-sdk

    git

    jetbrains.intellij-idea-community
    jetbrains.intellij-idea-ultimate
    jetbrains.pycharm-community
    jetbrains.pycharm-professional
    jetbrains.rider
    jetbrains.clion
    jetbrains.webstorm

    gimp

    vesktop

    vlc

    steamcmd
    steam-tui

    spotifyd
    spotify-tui
  ];

  services.xserver.enable = false;

  services.xserver.windowManager.sway = {
    enable        = true;
    extraPackages = [ pkgs.wl-clipboard ];
    config        = ''
      # Modifier
      set $mod Mod4

      # Terminal
      set $term foot

      # Window focus
      bindsym $mod+Left  focus left
      bindsym $mod+Down  focus down
      bindsym $mod+Up    focus up
      bindsym $mod+Right focus right

      # Spawn default terminal
      bindsym $mod+Return exec $term

      # Directional splits + spawn terminal
      bindsym $mod+Ctrl+Right split right; exec $term
      bindsym $mod+Ctrl+Left  split left;  exec $term
      bindsym $mod+Ctrl+Up    split up;    exec $term
      bindsym $mod+Ctrl+Down  split down;  exec $term

      # Close
      bindsym $mod+Shift+q kill

      # Workspace nav
      bindsym $mod+Shift+Right workspace next
      bindsym $mod+Shift+Left  workspace prev
      bindsym $mod+1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+7 workspace number 7
      bindsym $mod+8 workspace number 8
      bindsym $mod+9 workspace number 9
      bindsym $mod+0 workspace number 10

      exec_always swaybg -i preferences.backgroundPath -m fill

      # (Optional) Borders & gaps
      # default_border pixel 2
      # gaps inner 10
      # gaps outer 5
    '';
  };

  environment.shellInit = ''
  browser() {
    local url="${1:-${preferences.defaultWebPage}}"
    firefox --new-window --app="$url"
  }

  web() { browser "$@"; }
  yt() { browser "https://www.youtube.com"; }
  youtube() { browser "https://www.youtube.com"; }
  '';
}
