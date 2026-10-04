outputs = { self, nixpkgs, home-manager, disko, ... }: 
let
  system = "x86_64-linux";
  userSettings = builtins.fromTOML (builtins.readFile ./settings.toml);
  keybinds = builtins.fromTOML (builtins.readFile ./keybinds.toml);

  hostsDir = builtins.readDir ./hosts;
  hostNames = builtins.filter (name: hostsDir.${name} == "directory") (builtins.attrNames hostsDir);

  mkHost = hostName: nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit userSettings keybinds; };
    modules = [
      ./hosts/${hostName}/default.nix
      ./configuration.nix
      disko.nixosModules.disko
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit userSettings keybinds; };
        
        home-manager.users.matej = {
          imports = [ ./matej.nix ] 
            ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${hostName}/home.nix) ./hosts/${hostName}/home.nix;
        };
      }
    ];
  };
in {
  nixosConfigurations = nixpkgs.lib.genAttrs hostNames mkHost;

  packages.${system}.iso = (nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ({ config, pkgs, ... }: {
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # Launch interactive installer on TTY1 upon boot
        systemd.services.guided-installer = {
          description = "Guided NixOS Host Installer";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "idle";
            StandardInput = "tty";
            StandardOutput = "tty";
            StandardError = "tty";
            TTYPath = "/dev/tty1";
            TTYReset = true;
            TTYVHangup = true;
            TTYVTDisallocate = true;
          };
          path = with pkgs; [ git nix util-linux bash coreutils disko gawk gnugrep ];
          script = ''
            clear
            echo "==> Auto-mounting Ventoy storage drive..."
            mkdir -p /mnt/usb
            mount /dev/disk/by-label/Ventoy /mnt/usb 2>/dev/null || mount /dev/sda1 /mnt/usb 2>/dev/null

            if [ -d "/mnt/usb/my-nixos-config-main" ]; then
              cd /mnt/usb/my-nixos-config-main
              bash install.sh
            else
              echo "Error: Repository folder 'my-nixos-config-main' not found on USB!"
              bash
            fi
          '';
        };
      })
    ];
  }).config.system.build.isoImage;
};