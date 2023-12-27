{ config, lib, pkgs, ... }:
let extensions = (pkgs.callPackage ./firefox-extensions.nix { });
in {

  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = 1;
    MOZ_ALLOW_DOWNGRADE = 1;
  };

  programs.firefox = {
    enable = true;
    # https://github.com/bandithedoge/nixpkgs-firefox-darwin/blob/main/overlay.nix
    package = pkgs.firefox-bin;
    # open -na Firefox
    profiles.torgeir = {
      id = 0;
      settings = { };
      extensions = [
        extensions.darkreader
        extensions.vimium-ff
        extensions.ublock-origin
        extensions.multi-account-containers
        extensions.firefox-color
        extensions.onepassword-x-password-manager
      ];
    };
    # open -na Firefox --args -P work
    profiles.work = {
      id = 1;
      settings = { };
      extensions = [ extensions.vimium-ff extensions.ublock-origin ];
    };

    policies = {
      Preferences = let
        locked-false = {
          Value = false;
          Status = "locked";
        };
      in { };

    };
  };
}
