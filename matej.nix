{config, pkgs, lib, cfg, ...}:

  let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
  in
{
  home.username = "matej";
  home.homeDirectory= "/home/matej";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    discord
    vscodium
    vlc
    stremio
    python3
    nerd-fonts.iosevka
   ];

  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "www.google.com";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"

        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Privacy Badger:
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          # 1Password:
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
        };
  
        Preferences = { 
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.formfill.enable" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        };
      };
    };
  };
  fonts.fontconfig.enable = true;

#  programs.bash.enable = false;

 programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Iosevka Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "Iosevka Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "Iosevka Nerd Font";
          style = "Italic";
        };
        size = 11.0;
      };
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      sh = "swayhide";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      # You can customize more here:
      # prompt_order = [ "directory" "git_branch" "git_status" ];
      format = "$all";
      character = {
      success_symbol = "[->](bold green)";
      error_symbol = "[->](bold red)";
      vicmd_symbol = "[<-](bold yellow)";
      };
    };
  };

  services.gnome-keyring.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      input = {
        "*" = {
          xkb_layout = "hr";
          tap = "enabled";
          natural_scroll = "enabled";
          pointer_accel = "0.55";
        };
      };
      fonts = {
        names = ["Iosevka Nerd Font"];
      };

      terminal = "alacritty";

    keybindings = 
       let
         mod = config.wayland.windowManager.sway.config.modifier;
         cfg = config.wayland.windowManager.sway.config;
      in lib.mkOptionDefault {
        "${mod}+Return" = "exec ${cfg.terminal}";
        "${mod}+delete" = "kill";
        "${mod}+d" = "exec ${cfg.menu}";
        "${mod}+ctrl+Left" = "move left";
        "${mod}+ctrl+Down" = "move down";
        "${mod}+ctrl+Up" = "move up";
        "${mod}+ctrl+Right" = "move right";
      };
    };

  
#    environment.loginShellInit = ''
 #   [[ "$(tty)" == /dev/tty1 ]] && sway
#  '';
  };

  xdg.configFile."lsd/config.yaml".text = ''
    sorting:
      column: name
      order: ascending
      dir-grouping: first
    classic: false

    blocks:
      - permission
      - size
      - date
      - name
  '';
}
