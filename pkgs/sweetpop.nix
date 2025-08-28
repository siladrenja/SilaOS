# /etc/nixos/pkgs/sweetpop.nix
{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "sweet-pop";
  version = "2025-08-23";

  src = builtins.fetchTarball {
    url = "https://github.com/PROxZIMA/Sweet-Pop/archive/refs/tags/4.0.1.tar.gz";
    sha256 = "sha256:0kqzwnlk4ar2cnl5z1jkf570pyjy4ynxr07v6k6h7j1z95a7sz1m";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/sweet-pop
    cp -r . $out/share/sweet-pop/
  '';

  license = lib.licenses.unfree.shortName;
  meta = with lib; { description = "Sweet-Pop theme"; homepage = "https://github.com/PROxZIMA/Sweet-Pop"; };
}
