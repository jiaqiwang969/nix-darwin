{
  description = "Nix for macOS configuration";

  nixConfig = {
    substituters = [
      # 国内镜像源优先
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      # 官方源作为备用
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # format https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  inputs = {
    # nixpkgs 24.11 预发布版本
    # 2024-03-15
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # nix-darwin 24.11
    # 2024-03-15
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    
    # home-manager 24.11
    # 2024-03-15
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # firefox-darwin latest
    # 2024-03-15
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    # mkAlias latest
    # 2024-03-15
    mkAlias = {
      url = "github:cdmistman/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # nixpkgs unstable channel
    # 2024-03-15
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # specific nixpkgs version
    # 2024-03-15
    nixpkgs-locked.url = "github:NixOS/nixpkgs/nixos-24.11";

    # personal configs (local paths)
    nix-home-manager.url = "path:./nix-home-manager";
    dotfiles.url = "path:./dotfiles";

    # utils
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, nix-home-manager
    , dotfiles, ... }: {
      darwinConfigurations."JQdeMacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # apple silicon
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = [
              # pkgs.firefox-bin
              inputs.nixpkgs-firefox-darwin.overlay

              # use selected unstable packages with pkgs.unstable.xyz
              # https://discourse.nixos.org/t/how-to-use-nixos-unstable-for-some-packages-only/36337
              # "https://github.com/ne9z/dotfiles-flake/blob/d3159df136294675ccea340623c7c363b3584e0d/configuration.nix"
              (final: prev: {
                unstable =
                  import inputs.nixpkgs-unstable { system = prev.system; };
              })

              (final: prev: {
                # pkgs.unstable-locked.<something>
                unstable-locked =
                  import inputs.nixpkgs-locked { system = prev.system; };
              })

              (final: prev: {
                # https://github.com/nix-community/home-manager/issues/1341#issuecomment-1468889352
                mkAlias =
                  inputs.mkAlias.outputs.apps.${prev.system}.default.program;
              })

            ];
          }
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/host-users.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jqwang = import ./home;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              dotfiles = dotfiles;
              # hack around nix-home-manager causing infinite recursion
              isLinux = false;
            };
          }
        ];
      };
    };
}
