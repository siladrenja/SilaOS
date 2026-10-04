{config, pkgs, lib, userSettings, osConfig, keybinds, ...}:

  let
    c = userSettings.colors;

    rawWallpaper = userSettings.theme.wallpaper_path;
    isWebWallpaper = lib.hasPrefix "http" rawWallpaper;

    localWallpaperPath = lib.replaceStrings 
    ["~/"] 
    ["${userSettings.user.home_dir}/"] 
    rawWallpaper;

    wallpaper = if isWebWallpaper then 
    pkgs.fetchurl {
      url = rawWallpaper;
      sha256 = userSettings.theme.wallpaper_hash;
      name = "wallpaper";
    }
    else
      localWallpaperPath;

    resolveCmd = cmd:
    if lib.hasPrefix "@" cmd then
      # Strip the "@" and look up the target app's command dynamically
      userSettings.apps.${lib.removePrefix "@" cmd}.cmd
    else
      cmd;
    appPkgsList = builtins.map (app: 
    let
      pkgName = app.pkg or app.cmd;
    in
      if pkgName == "disabled" then 
        null
      else 
        lib.getAttrFromPath (lib.splitString "." pkgName) pkgs
  ) (builtins.attrValues userSettings.apps);

  autoInstalledApps = builtins.filter (p: p != null) appPkgsList;
    
    customIcons = pkgs.callPackage ./pkgs/custom-icons.nix { inherit userSettings; };
    customScripts = pkgs.callPackage ./pkgs/custom-scripts.nix {};

    essential-dark-theme = pkgs.fetchFromGitHub {
      owner = "GiorgioReale";
      repo = "Ulauncher-Essential-Dark-Theme";
      rev = "2b8b2e8";
      sha256 = "sha256-f/QWyLRYXGQ6ZRX+zhNt5kmxgFYtfg4XvV+Wl0dT9NE=";
    };

    desktopEntries = lib.mapAttrs (key: app: {
      name = app.name or key;
      exec = resolveCmd app.cmd;
      terminal = app.terminal or false;
      categories = [ "Utility" ];
    }) userSettings.apps;
  in
{

  home.username = "matej";
  home.homeDirectory= "/home/matej";
  home.stateVersion = "26.05";

  imports = [
    ./programs/hyprland.nix
    ./programs/firefox.nix
  ];

  home.packages = with pkgs; [
    lazygit
    unzip
    xwayland
    gcc
    rocmPackages.llvm.clang-unwrapped
    imv
    wdisplays
    gnumake
    cmake
    docker
    spotify
    grim
    slurp
    wl-clipboard
    ulauncher
    usbutils
    cliphist  
    zip
    micro
    libnotify
    swaynotificationcenter
    gemini-cli
    playerctl
    wtype
    parted
    sl
    asciiquarium
    windowtolayer
    mediainfo
    ouch
    gitui
    gprof2dot
    graphviz
    mdr
    typst
    pandoc
    (thunar.override { thunarPlugins = [ pkgs.thunar-volman ]; })
	flat-remix-gtk
    tumbler
    ffmpegthumbnailer
    elephant
    walker
    libqalculate
    pkg-config
    ffmpeg-full
    gcalcli

    customIcons.customCandyIcons
    customIcons.customSweetFolders
    customScripts.rofi-power
    customScripts.calendar-widget
    (pkgs.callPackage ./pkgs/waybar-ycal.nix {})
    (pkgs.callPackage ./pkgs/nextmeeting.nix {})
   ] ++ autoInstalledApps;


  home.file = {
    ".themes/Flat-Remix-GTK-Cyan-Darkest".source = "${pkgs.flat-remix-gtk}/share/themes/Flat-Remix-GTK-Cyan-Darkest";
    ".icons/candy-icons".source = "${customIcons.customCandyIcons}/share/icons/candy-icons";
  };

  home.file.".config/omarchy/current/theme/colors.toml".text = ''
      foreground = "#${c.text}"
      background = "#${c.background}"
      accent = "#${c.primary}"
    '';

  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
    theme = "Arc-Dark";
  };

  

  fonts.fontconfig.enable = true;

#  programs.bash.enable = false;

 programs.ghostty = {
  enable = true;
  settings = {
    font-family = userSettings.terminal.font_family;
    font-size = userSettings.terminal.font_size;
    # Smart Copy/Paste logic we discussed:
    keybind = [
      "performable:ctrl+c=copy_to_clipboard"
      "ctrl+v=paste_from_clipboard"
    ];
    # Aesthetic tweaks for Hyprland
    window-decoration = false;
    confirm-close-surface = false;
    background = "#${c.background}";
    foreground = "#${c.text}";
    app-notifications = "false";
    resize-overlay = "never";

    background-opacity = userSettings.terminal.opacity;
    unfocused-split-opacity = userSettings.terminal.opacity;
  };
};

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      edit = resolveCmd userSettings.apps.editor.cmd;
      browser = resolveCmd userSettings.apps.browser.cmd;
      explorer = resolveCmd userSettings.apps.explorer.cmd;
      tasks = resolveCmd userSettings.apps.tasks.cmd;
      img = resolveCmd userSettings.apps.image_viewer.cmd;
      term = resolveCmd userSettings.apps.terminal.cmd;
      pdf = resolveCmd userSettings.apps.pdf_viewer.cmd;
      media = resolveCmd userSettings.apps.media_player.cmd;
      sysinfo = resolveCmd userSettings.apps.fetch.cmd;
      
      config = "${resolveCmd userSettings.apps.editor.cmd} ~/nixos-config/settings.toml";
      settings = "${resolveCmd userSettings.apps.editor.cmd} ~/nixos-config/settings.toml";
      
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#${osConfig.networking.hostName}";
    };
    functions = {
      fcp = {
        description = "Copy file(s) to clipboard using text/uri-list for Wayland";
        body = ''
          set -l uris
          for arg in $argv
              # This handles relative paths and turns them into absolute file:// URIs
              set -a uris "file://"(realpath $arg)
          end

          if count $uris > /dev/null
              # IMPORTANT: text/uri-list requires \r\n (CRLF) separation for multiple items
              string join \r\n $uris | wl-copy --type text/uri-list
              echo "Copied "(count $uris)" file(s) to clipboard."
          else
              echo "Usage: fcp <file1> [file2] ..."
          end
        '';
      };
    };
    loginShellInit = ''
      if test (tty) = "/dev/tty1"
        exec start-hyprland
      end
    '';
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

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        fade_in = {
          duration = 300;
          bezier = "easeOutQuint";
        };
        fade_out = {
          duration = 300;
          bezier = "easeOutQuint";
        };
      };

      background = [
        {
          path = "${wallpaper}";
          blur_passes = 0;
          blur_size = 0;
        }
      ];

      label = [
        {
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgb(202, 211, 245)";
          font_size = 120;
          font_family = "iosevka";

          shadow_passes = 3;
          shadow_size = 4;
          shadow_color = "rgb(24, 25, 38)";
          shadow_boost = 1.2;

          position = "0, 50";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = '''<span foreground="##cad3f5">Password...</span>' '';
          shadow_passes = 2;
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      
      preload = [ 
        "${wallpaper}" 
      ];
      
      wallpaper = [
              {
                monitor = "";
                path = "${wallpaper}";
                fit_mode = "cover";
              }
            ];
    };
  };

  home.sessionVariables = 
  {
    XCURSOR_THEME = userSettings.theme.cursor_theme;
    XCURSOR_SIZE = builtins.toString userSettings.theme.cursor_size;
    MOZ_ENABLE_WAYLAND = "1";
    EDITOR = resolveCmd userSettings.apps.editor.cmd;
    VISUAL = resolveCmd userSettings.apps.editor.cmd;
    BROWSER = resolveCmd userSettings.apps.browser.cmd;
    TERMINAL = resolveCmd userSettings.apps.terminal.cmd;
    EXPLORER = resolveCmd userSettings.apps.explorer.cmd;
    PAGER = resolveCmd userSettings.apps.pager.cmd;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";  
        before_sleep_cmd = "loginctl lock-session";
      
        after_sleep_cmd = "hyprctl dispatch dpms on";     
      };

      listener = [
        {
          timeout = 300;                                
          on-timeout = "pidof hyprlock && systemctl suspend-then-hibernate"; 
        }
        {
          timeout = 600;                                
          on-timeout = "hyprctl dispatch dpms off";     
          on-resume = "hyprctl dispatch dpms on";       
        }
        {
          timeout = 1800;                               
          on-timeout = "systemctl suspend-then-hibernate"; 
        }
      ];
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = userSettings.theme.cursor_theme;
    package = pkgs.breeze-hacked-cursor-theme;
    size = userSettings.theme.cursor_size;
  };

  gtk = {
      enable = true;
      theme = {
        name = userSettings.theme.gtk_theme;
        package = pkgs.flat-remix-gtk;
      };
      iconTheme = {
        name = userSettings.theme.icon_theme;
        package = customIcons.customCandyIcons;
      };
  
      gtk4.theme = config.gtk.theme;
    };

 programs.waybar = {
  enable = true;

  settings = {
    mainBar = {
      layer = "top";
      position = "top";

      modules-left = [ "hyprland/workspaces" "sway/workspaces" ];
      modules-center = [ "custom/player_previous" "mpris" "custom/spotify_volume" "custom/player_next" ];

      modules-right = [ "custom/upcoming_event" "battery" "pulseaudio" "clock" "custom/swaync" "custom/power"];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "hyprctl dispatch workspace {name}";
      };

      "custom/power" = {
          format = "⏻"; # Or any Nerd Font icon you prefer
          on-click = "rofi-power";
          tooltip = false;
        };

      "mpris" = {
        format = "{player_icon} {title} | {artist}";
        format-paused = "{status_icon} {title} | {artist}";
        # Force the module to only listen to Spotify
        player = "spotify"; 
        player-icons = {
          spotify = "";
        };
        status-icons = {
          paused = "";
        };
        # Ensure these specific actions only target Spotify
        on-click = "playerctl --player=spotify play-pause";
        on-scroll-up = "playerctl --player=spotify next";
        on-scroll-down = "playerctl --player=spotify previous";
      };

      "custom/player_previous" = {
        format = "";
        on-click = "playerctl --player=spotify previous";
        tooltip = false;
      };

      "custom/player_next" = {
        format = "";
        on-click = "playerctl --player=spotify next";
        tooltip = false;
      };

      "custom/spotify_volume" = {
        format = "󰓃 {}%";
        # Fetches volume, multiplies by 100, and rounds to nearest whole number
        exec = "playerctl --player=spotify volume | awk '{print int($1*100)}'";
        interval = 2; # Update every 2 seconds
        on-scroll-up = "playerctl --player=spotify volume 0.05+";
        on-scroll-down = "playerctl --player=spotify volume 0.05-";
        tooltip = false;
      };

      pulseaudio = {
            format = "{icon}  {volume}%";
            format-muted = "󰖁  Muted";
            format-icons = {
              headphone = "";
              default = ["" "" ""];
            };
            # How much the volume changes per scroll tick
            scroll-step = 5; 

            # Optional: right-click to mute/unmute
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; 
      };

      "custom/swaync" = {
            tooltip = false;
            format = "{icon} ";
            format-icons = {
              notification = ""; # Icon when there is an unread notification
              none = "";         # Icon when tray is empty
              dnd-notification = "";
              dnd-none = "";
            };
            return-type = "json";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t -sw";
            on-click-right = "swaync-client -d -sw";
            escape = true;
          };
      "custom/upcoming_event" = {
              exec = "upcoming-event-filter";
              return-type = "json";
              interval = 60;
              on-click = "nextmeeting --open-meet-url"; 
            };

      battery = {
      format = "{icon}{capacity}%";
      format-charging = "⚡{capacity}%";
      icons = [ "" "" "" "" "" ];
      };


      clock = {
        format = "{:%Y-%m-%d %H:%M}";
        interval = 60;
        on-click = "waybar-ycal-toggle";
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
        background: rgba(0,0,0,0.7); /* Can also use #${c.background} */
        color: #${c.text};
      }

      #workspaces button {
        color: #${c.text_dim};
      }

      #workspaces button.active {
        color: #${c.text};
        border-bottom: 2px solid #${c.primary};
      }

      @keyframes blink {
        0% { color: #${c.text}; }
        50% { color: #${c.urgent}; } 
        100% { color: #${c.text}; }
      }

      #workspaces button.urgent {
        color: #${c.text};
        background-color: #${c.urgent};
        animation: blink 1s linear infinite;
      }

    mpris,
    #mpris.playing,
    #mpris.paused,
    #custom-player_previous,
    #custom-player_next {
      background: transparent;
      background-color: transparent;
      color: #ffffff;
      box-shadow: none;
    }

    #custom-player_previous,
    #custom-player_next {
      padding: 0 4px;
      color: #cccccc;
    }
    
    #custom-player_previous:hover,
    #custom-player_next:hover {
      color: #33ccff;
    }

    #mpris.paused {
      opacity: 0.4;
      font-style: italic;
    }

  '';

};

  programs.vscode = {
      enable = true;   
  };

  xdg.configFile = {
    "swaync/config.json".text = builtins.toJSON {
      "scripts" = {};
      "notification-visibility" = {
        "spotify" = {
          "state" = "ignored";
          "app-name" = "Spotify";
        };
      };
    };
    "swaync/style.css".text = ''
              /* Main notification background */
              .notification {
                background: rgba(0, 0, 0, 0.7); 
                border: 1px solid #${c.primary}; 
                color: #${c.text};
                border-radius: 0;
                margin: 0;
                box-shadow: none;
              }
        
              /* Text and Content */
              .notification-content {
                background: transparent;
                padding: 6px;
              }
              
              .summary {
                color: #${c.text};
                font-weight: bold;
              }
        
              .body {
                color: #${c.text_dim}; 
              }
        
              /* Control Center Panel (Slide-out menu) */
              .control-center {
                background: #${c.background};
                border: 1px solid #${c.primary};
                color: #${c.text};
                border-radius: 0;
              }
        
              .widget-title {
                color: #${c.text};
                font-size: 14px;
                margin: 10px;
              }
              
              .widget-dnd {
                background: transparent;
                color: #${c.text};
              }
              
              .close-button {
                background: transparent;
                color: #${c.urgent};
                border-radius: 0;
              }
            '';

    "lsd/config.yaml".text = ''
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

    "ulauncher/user-themes/Essential-Dark" = {
      source = essential-dark-theme;
      recursive = true;
    };

    "walker/config.toml".text = ''
      click_to_close = true

      [search]
      placeholder = "Search apps or type math..."
      clear_icon = "" 

      [providers]
      default = ["desktopapplications", "calc", "runner", "websearch"]

      [providers.desktopapplications]
      weight = 100

      [providers.calc]
      require_prefix = false
      weight = 50
    '';
  };
  xdg.desktopEntries = desktopEntries;

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    plugins = with pkgs.yaziPlugins; {
      git = git;
      sudo = sudo;
      ouch = ouch;
      mount = mount;
      gitui = gitui;
      lazygit = lazygit;
      starship = starship;
      mediainfo = mediainfo;
    };

    settings = {
      plugin = {
        prepend_previewers = [
          { name = "*.{zip,rar,tar,gz,bz2,xz,7z}"; run = "ouch"; }
          { name = "*.{mp4,mkv,avi,mp3,flac}"; run = "mediainfo"; }
        ];
        prepend_fetchers = [
          { id = "git"; name = "~/dev/**"; run = "git"; }
        ];
      };
      opener = {
        extract = [
        	{ run = "ouch d -y %*"; desc = "Extract here with ouch"; for = "windows"; }
        	{ run = "ouch d -y \"$@\""; desc = "Extract here with ouch"; for = "unix"; }
        ];
      };
    };

    keymap = {
      manager = {
        prepend_keymap = [
          { on = [ "s" ]; run = "plugin sudo"; desc = "Open with sudo"; }
          { on = [ "m" ]; run = "plugin mount"; desc = "Mount drive"; }
          { on = [ "g" "g" ]; run = "plugin lazygit"; desc = "Open lazygit"; }
          { on = [ "g" "i" ]; run = "plugin gitui"; desc = "Open gitui"; }
          { on = [ "x" "c" ]; run = "plugin ouch compress"; desc = "compress file"; }
        ];
      };
    };

    theme = {
    status = {
      sep_left  = { open = ""; close = ""; };
      sep_right = { open = ""; close = ""; };
    };
  };

    initLua =
    ''
      require("starship"):setup()
    '';
 };

 programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };


    qt = {
      enable = true;
      platformTheme.name = "gtk";

      #gtk
    };

  services.gnome-keyring.enable = true;
}
