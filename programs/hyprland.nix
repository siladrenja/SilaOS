{ config, pkgs, userSettings, keybinds, lib, monitorLUT ? [], ... }:

let
  resolveCmd = cmd:
    if lib.hasPrefix "@" cmd then
      userSettings.apps.${lib.removePrefix "@" cmd}.cmd
    else
      cmd;

  validMonitors = builtins.filter (mon: mon.port < builtins.length monitorLUT) userSettings.monitors;

  monitorConfig = lib.foldl' (acc: mon: 
    let
      portName = builtins.elemAt monitorLUT mon.port;
      isAuto = (mon.resolution or "") == "auto";

      canUseMath = acc.mathValid && !isAuto;

      resStr = if isAuto then "preferred" else "${toString mon.width}x${toString mon.height}@${toString mon.refresh}";
      
      posStr = if canUseMath then "${toString acc.x}x0" else "auto";

      nextX = if canUseMath then acc.x + mon.width else 0;

    in {
      x = nextX;
      mathValid = canUseMath;
      lines = acc.lines ++ [
        "${portName}, ${resStr}, ${posStr}, ${toString mon.scale}"
      ];
    }
  ) { x = 0; mathValid = true; lines = []; } validMonitors;

  c = userSettings.colors;

in
{
    wayland.windowManager.hyprland = {
    enable = true;

	configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = resolveCmd userSettings.apps.terminal.cmd;

      input = {
        kb_layout = "hr";
        sensitivity = 0.55;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
         
        follow_mouse = 2;
        mouse_refocus = false;
        float_switch_override_focus = 0;
      };

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 1;
        resize_on_border = true;
        "col.active_border" = "rgba(${c.primary}ff)";
        "col.inactive_border" = "rgba(${c.background_alt}aa)";
      };

      dwindle = {
          preserve_split = true;
        };

      decoration = {
        rounding = 0;
        blur = {
          enabled = false;
        };
      };

      animations = {
        enabled = false;
      };

      cursor = {
        no_hardware_cursors = 1;
      };

      misc = {
        enable_swallow = false;
        swallow_regex = ".*";                
        swallow_exception_regex = ""; 
        focus_on_activate = false;       
      };

      env = [
        "XCURSOR_THEME,Breeze_Hacked"
        "XCURSOR_SIZE,18"
      ];

      exec-once = [ 
      	"hyprctl setcursor ${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}"
      	"waybar" 
      	"wl-paste --type text --watch cliphist store"
      	"wl-paste --type image --watch cliphist store"
      	"swaync"
      	"[workspace special:music silent] spotify"
      	"elephant" 
      	"walker --gapplication-service"
      ];

      bind = [
        "$mod, ${keybinds.terminal}, exec, $terminal"
        "$mod, ${keybinds.close}, killactive"
        "$mod, ${keybinds.new}, exec, walker"
        "$mod, ${keybinds.lock}, exec, loginctl lock-session"
        "$mod, ${keybinds.notifications}, exec, swaync-client -t -sw"
        
        "$mod, ${keybinds.nav_left}, workspace, m-1"
        "$mod, ${keybinds.nav_right}, workspace, m+1"

        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, V, exec, cliphist list | rofi -dmenu -theme-str 'listview {columns: 1; lines: 10;} element {orientation: horizontal;}' | cliphist decode | tee >(wl-copy) | wtype -"
        "$mod SHIFT, W, exec, hyprctl dispatch dpms on"
        "$mod, N, exec, swaync-client -t -sw"
        "$mod, TAB, exec, hyprctl dispatch splitratio exact 0.5"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        "$mod, S,     movetoworkspace, special:minimized"
        "$mod, grave, togglespecialworkspace, minimized"
        "$mod, M,     togglespecialworkspace, music"

        "$mod CTRL, left, movecurrentworkspacetomonitor, l"
        "$mod CTRL, right, movecurrentworkspacetomonitor, r"
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          let
            ws = if i == 9 then 10 else i + 1;
            key = if i == 9 then "0" else builtins.toString (i + 1);
          in [
            "$mod, ${key}, workspace, ${builtins.toString ws}"
            "$mod SHIFT, ${key}, movetoworkspace, ${builtins.toString ws}"
            "$mod CTRL, ${key}, movecurrentworkspacetomonitor, ${builtins.toString ws}"
          ]
        ) 10)
      );

      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        
        ", XF86Tools, togglespecialworkspace, music"
        "$mod SHIFT, M,     togglespecialworkspace, music"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      windowrule = [
              "match:class ^(Spotify)$, workspace special:music"
              "match:float true, no_max_size on"
            ];

      decoration = {
        active_opacity = 1.0;
        inactive_opacity = 0.9;
      };

      monitor = monitorConfig.lines ++ [
        ",preferred,auto,1" 
      ];
    };
  };
}
