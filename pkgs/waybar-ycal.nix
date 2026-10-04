{ lib, stdenv, fetchFromGitHub, python3, gtk4, gtk4-layer-shell, gobject-introspection, wrapGAppsHook4 }:

let
  pythonEnv = python3.withPackages (p: with p; [
    pygobject3
    google-api-python-client
    google-auth-oauthlib
    google-auth
  ]);
in
stdenv.mkDerivation rec {
  pname = "waybar-ycal";
  version = "main"; 

  src = fetchFromGitHub {
    owner = "yagybaba";
    repo = "waybar-ycal";
    rev = "main";
    hash = "sha256-Pp4mO5oxl3uENmKBvNeUev/bK4YzwBZElAcHisksKe4="; 
  };

  nativeBuildInputs = [ wrapGAppsHook4 gobject-introspection ];
  
  buildInputs = [
    gtk4
    gtk4-layer-shell
    pythonEnv
  ];

  postPatch = ''
    sed -i 's|os.path.dirname(os.path.realpath(__file__))|os.path.expanduser("~/.config/waybar-ycal")|g' *.py
    sed -i 's|os.path.dirname(__file__)|os.path.expanduser("~/.config/waybar-ycal")|g' *.py
    sed -i "s|'libgtk4-layer-shell.so'|'${gtk4-layer-shell}/lib/libgtk4-layer-shell.so'|g" popup.py
    
    # Anchor to the right edge
    sed -i 's/Gtk4LayerShell.Edge.RIGHT, False/Gtk4LayerShell.Edge.RIGHT, True/g' popup.py
    sed -i 's/Gtk4LayerShell.Edge.LEFT, True/Gtk4LayerShell.Edge.LEFT, False/g' popup.py
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/waybar-ycal
    cp -r * $out/share/waybar-ycal
    
    cat << 'EOF' > $out/share/waybar-ycal/css_inject.py
import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gdk, GLib

def _apply_custom_css():
    display = Gdk.Display.get_default()
    if display:
        p = Gtk.CssProvider()
        p.load_from_data(b"window { background-color: rgba(0, 0, 0, 0.01); box-shadow: none; } * { border-radius: 0px; }")
        Gtk.StyleContext.add_provider_for_display(display, p, 9999)
        return False
    return True

GLib.idle_add(_apply_custom_css)
EOF

    cat $out/share/waybar-ycal/css_inject.py $out/share/waybar-ycal/popup.py > $out/share/waybar-ycal/popup_new.py
    mv $out/share/waybar-ycal/popup_new.py $out/share/waybar-ycal/popup.py

    makeWrapper ${pythonEnv.interpreter} $out/bin/waybar-ycal-bar \
      --add-flags "$out/share/waybar-ycal/bar.py"
      
    # Preload libgtk4-layer-shell.so so GTK initializes layer surfaces correctly
    makeWrapper ${pythonEnv.interpreter} $out/bin/waybar-ycal-popup \
      --add-flags "$out/share/waybar-ycal/popup.py" \
      --prefix LD_PRELOAD : "${gtk4-layer-shell}/lib/libgtk4-layer-shell.so"
      
    cat > $out/bin/waybar-ycal-toggle << EOF
#!/usr/bin/env bash
if ! pgrep -f "waybar-ycal/popup.py" > /dev/null; then
  $out/bin/waybar-ycal-popup &
  sleep 0.5
else
  pkill -SIGUSR1 -f "waybar-ycal/popup.py"
fi
EOF
    chmod +x $out/bin/waybar-ycal-toggle
  '';
}
