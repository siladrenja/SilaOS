{ config, pkgs, userSettings, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
      languagePacks = [ "en-US" ];
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = false;
          Cryptomining = true;
          Fingerprinting = true;
          Exceptions = [
            "https://mail.google.com"
            "https://meet.google.com"
            "https://chat.google.com"
          ];
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = userSettings.browser.default_page;
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
        ExtensionSettings = {
          "*" = {
            installation_mode = "blocked";
          };
          "{c933beb8-06cc-4278-ac6a-d7b4552e487f}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/full-black43289352/latest.xpi";
          };
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          "Shortkeys@brian.reavis" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/shortkeys/latest.xpi";
          };
        };
  
        Preferences = { 
          "extensions.activeThemeID" = "{765509df-67f7-43c3-9f44-8d48750800e8}";
          "ui.systemUsesDarkTheme" = 1;
          "layout.css.prefers-color-scheme.content-override" = 0;
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.formfill.enable" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          "media.webrtc.camera.allow-pipewire" = lock-false;
        };
      };
    };
}
