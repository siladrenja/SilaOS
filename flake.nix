{
  description = "Matej's Multi-Host NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
    ({ config, pkgs, lib, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Override default 'nixos' autologin user using lib.mkForce
      services.getty.autologinUser = lib.mkForce "root";

      # Embed your nixos-config repository directly into the ISO build
      environment.etc."nixos-config".source = ./.;

      environment.systemPackages = with pkgs; [
        disko
        git
        util-linux
        gawk
        gnugrep
        parted
      ];

      # Auto-run installer from the embedded repository on boot
      programs.bash.loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
          clear
          echo "===================================================="
          echo "      NixOS Guided Installer (Embedded Repo)       "
          echo "===================================================="

          if [ -d "/etc/nixos-config" ]; then
            # Copy embedded repo to writable RAM directory so hardware-config & locks can be written
            rm -rf /tmp/nixos-config
            cp -r /etc/nixos-config /tmp/nixos-config
            cd /tmp/nixos-config
            bash install.sh
          fi
        fi
      '';
    })
  ];
}).config.system.build.isoImage;
  };
}