{ pkgs }:

{
  rofi-power = pkgs.writeShellScriptBin "rofi-power" ''
    #!/bin/sh
    options="Logout\nSuspend\nHibernate\nReboot\nShutdown"
    chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power")
    case "$chosen" in
      "Logout") hyprctl dispatch exit ;;
      "Suspend") systemctl suspend ;;
      "Hibernate") systemctl hibernate ;;
      "Reboot") systemctl reboot ;;
      "Shutdown") systemctl poweroff ;;
    esac
  '';

  calendar-widget = pkgs.writeShellScriptBin "calendar-widget" ''
    #!/usr/bin/env bash
    
    # 1. Get a simple calendar grid for the current month
    CAL=$(cal -m)
    
    # 2. Get the agenda for the next 7 days
    # --nocolor strips ANSI escape codes so Rofi renders the text cleanly
    AGENDA=$(gcalcli --nocolor agenda "$(date +%Y-%m-%d)" "$(date -d '+7 days' +%Y-%m-%d)")
    
    # 3. Pipe them together into Rofi
    echo -e "Calendar:\n$CAL\n\nAgenda:\n$AGENDA" | rofi -dmenu \
        -p "Calendar" \
        -theme-str 'listview { lines: 25; scrollbar: false; } window { width: 500px; }' \
        -kb-cancel 'Escape,MouseSecondary'
  '';

  notes = pkgs.writeShellScriptBin "notes" ''
    #!/bin/sh
    micro "$HOME/.notes.md"
  '';

  upcoming-event-filter = pkgs.writeShellScriptBin "upcoming-event-filter" ''
  #!/usr/bin/env python3
  import subprocess
  import datetime
  import json
  import sys
  
  def main():
      now = datetime.datetime.now()
      # Fetch events for today and tomorrow
      start_str = now.strftime('%Y-%m-%d')
      end_str = (now + datetime.timedelta(days=1)).strftime('%Y-%m-%d')
      
      try:
          # Run gcalcli silently and ask for tab-separated output
          cmd = ['gcalcli', 'agenda', start_str, end_str, '--tsv', '--details', 'all']
          output = subprocess.check_output(cmd, universal_newlines=True)
      except Exception:
          sys.exit(0)
  
      for line in output.strip().split('\n'):
          if not line: 
              continue
          parts = line.split('\t')
          
          if len(parts) < 5: 
              continue
              
          start_date, start_time = parts[0], parts[1]
          title = parts[4]
          
          try:
              start_dt = datetime.datetime.strptime(f"{start_date} {start_time}", "%Y-%m-%d %H:%M")
          except ValueError:
              continue
              
          diff = (start_dt - now).total_seconds() / 60.0
          
          # Strictly enforce the 60-minute limit
          if 0 < diff <= 60:
              print(json.dumps({
                  "text": f" {title} in {int(diff)}m",
                  "class": "imminent"
              }))
              sys.exit(0)
          elif diff > 60:
              # Events are chronological; if one is >60m away, stop checking
              break
  
      # Output empty string if nothing is imminent, hiding the Waybar module
      print("")
  
  if __name__ == '__main__':
      main()
      '';
}
