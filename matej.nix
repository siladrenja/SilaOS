{config, pkgs, lib, cfg, ...}:

{
  home.username = "matej";
  home.homeDirectory= "/home/matej";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    discord
    vscodium
    vlc
    stremio
    alacritty 
    python3
    iosevka
   ];
  
  fonts.fontconfig.enable = true;

#  programs.bash.enable = false;

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
        names = ["iosevka sans mono"];
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
}
