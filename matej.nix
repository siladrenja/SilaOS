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
  home.stateVersion = "25.05";

  nixpkgs.overlays = [
  (final: prev: {
    git = prev.gitFull;
    gitMinimal = prev.gitFull;
    gitWithSvn = prev.gitFull;
  })
];




  home.packages = with pkgs; [
    discord
    vscodium
    vlc
    stremio
    python3
    jetbrains.jdk
    jetbrains.clion
    jetbrains.idea-community
    jetbrains.rider
    gcc
    cmake
    spotify-player
    mc
    kdePackages.dolphin
    lazygit
    peazip
    unzip
    #wineWow64Packages.stable
    winetricks
    wineWow64Packages.waylandFull
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

  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "Iosevka Nerd Font:size=12";
        terminal = "alacritty";
        layer = "overlay"; 
     };
    };
  };
wayland.windowManager.hyprland = {
  enable = true;

  settings = {
    "$mod" = "SUPER";
    "$terminal" = "alacritty";

    ############################
    # INPUT
    ############################
    input = {
      kb_layout = "hr";
      sensitivity = 0.55;

      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
      };
       
      follow_mouse = 0;
      mouse_refocus = false;
    };

    ############################
    # NO GAPS, THIN BORDER
    ############################
    general = {
      gaps_in = 0;
      gaps_out = 0;
      border_size = 1;
    };

    ############################
    # DECORATION (VALID OPTIONS)
    ############################
    decoration = {
      rounding = 0;
      blur = {
        enabled = false;
      };
    };

    ############################
    # ANIMATIONS (VALID SYNTAX)
    ############################
    animations = {
      enabled = false;
    };



    ############################
    # CURSOR FIX
    ############################
    cursor = {
      no_hardware_cursors = false;
    };

    ############################
    # KEYBINDINGS
    ############################
    bind = [
      # basic
      "$mod, Return, exec, $terminal"
      "$mod, Delete, killactive"
      "$mod, Space, exec, fuzzel"

      # focus with arrows
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # move windows with mod+ctrl
      "$mod CTRL, left, movewindow, l"
      "$mod CTRL, right, movewindow, r"
      "$mod CTRL, up, movewindow, u"
      "$mod CTRL, down, movewindow, d"

      # workspaces 1–9
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"

      # move window to workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
    ];
  misc = {
    enable_swallow = true;
    swallow_regex = ".*";                # swallow everything
    swallow_exception_regex = "";        # no exceptions
  };
  exec-once = [ "waybar" ];
  };

  


};

programs.waybar = {
  enable = true;

  settings = {
  mainBar = {
    layer = "top";
    position = "top";

    modules-left = [ "hyprland/workspaces" ];
    modules-center = [ ];
    modules-right = [ "battery" "clock" ];

    "hyprland/workspaces" = {
      format = "{name}";
      on-click = "hyprctl dispatch workspace {name}";
    };

    battery = {
  format = "{icon}{capacity}%";
  format-charging = "⚡{capacity}%";
  icons = [ "" "" "" "" "" ];
};


    clock = {
      format = "{:%Y-%m-%d %H:%M}";
      interval = 60;
    };
  };
};


  style = ''
    * {
      font-family: "Symbols Nerd Font", monospace;
      font-size: 12px;
      padding: 0 6px;
    }

    window#waybar {
      background: rgba(0,0,0,0.7);
      color: #ffffff;
    }

    #workspaces button {
      padding: 0 4px;
      color: #cccccc;
    }

    #workspaces button.active {
      color: #ffffff;
      border-bottom: 2px solid #33ccff;
    }
  '';
};


home.sessionVariables = {
  XCURSOR_THEME = "Adwaita";
  XCURSOR_SIZE = "24";
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

  services.gnome-keyring.enable = true;

}

