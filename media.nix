{config, pkgs, lib, cfg, ...}:
{
	home.username = "media";
	home.homeDirectory = "/home/media";
	home.stateVersion = "25.05";

  home.packages = with pkgs; [
    (kodi.withPackages (kodiPkgs: with kodiPkgs; [
      inputstream-adaptive
      youtube
    ]))
    cage
    xwayland    
    stremio
    vlc
  ];
	
}

