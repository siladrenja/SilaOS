{ pkgs, userSettings }:

let
  wireframeColor = userSettings.theme.wireframe_color or userSettings.colors.primary;

  nukeColors = ''
    find $out/share/icons -type f -name "*.svg" -exec sed -i -E 's/#[a-fA-F0-9]{3,6}\b/#${wireframeColor}/g' {} +
    find $out/share/icons -type f -name "*.svg" -exec sed -i -E 's/(fill|stroke)="url\([^)]+\)"/\1="#${wireframeColor}"/g' {} +
    find $out/share/icons -type f -name "*.svg" -exec sed -i -E 's/(fill|stroke):[ ]*url\([^)]+\)/\1:#${wireframeColor}/g' {} +
    find $out/share/icons -type f -name "*.svg" -exec sed -i -E 's/rgba?\([^)]+\)/#${wireframeColor}/g' {} +
  '';

  customNixosLogo = pkgs.runCommand "monochrome-nixos-logo" {} ''
    mkdir -p $out
    cp ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg $out/nixos.svg
    
    sed -i -E 's/#[a-fA-F0-9]{3,6}\b/#${wireframeColor}/g' $out/nixos.svg
    sed -i -E 's/(fill|stroke)="url\([^)]+\)"/\1="#${wireframeColor}"/g' $out/nixos.svg
    sed -i -E 's/(fill|stroke):[ ]*url\([^)]+\)/\1:#${wireframeColor}/g' $out/nixos.svg
    sed -i -E 's/rgba?\([^)]+\)/#${wireframeColor}/g' $out/nixos.svg
  '';
in
{
  customCandyIcons = pkgs.candy-icons.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + nukeColors;
  });

  customSweetFolders = pkgs.sweet-folders.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + nukeColors + ''
      find $out/share/icons -name "folder.svg" | while read -r f; do
        dir=$(dirname "$f")
        cp "${customNixosLogo}/nixos.svg" "$dir/folder-nixos.svg"
        cp "${customNixosLogo}/nixos.svg" "$dir/folder-os-nixos.svg"
        cp "${customNixosLogo}/nixos.svg" "$dir/folder-nix.svg"
      done
    '';
  });
}
