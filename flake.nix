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
    # nixpkgs 23.11 darwin channel
    # 2024-01-31
    nixpkgs-darwin.url = "github:nixos/nixpkgs/7144d6241f02d171d25fba3edeaf15e0f2592105";
    
    # nix-darwin latest stable
    # 2024-03-01
    darwin = {
      url = "github:lnl7/nix-darwin/683d0c4cd1102dcccfa3f835565378c7f3cbe05e";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    
    # home-manager 23.11 release
    # 2024-01-30
    home-manager = {
      url = "github:nix-community/home-manager/f2e3c19867262dbe84fdfab42467fc8dd83a2005";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # firefox-darwin latest
    # 2024-01-21
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/8e9965c903e39aa478abe25e6f0a3a89370277a2";

    # mkAlias stable
    # 2023-03-12
    mkAlias = {
      url = "github:cdmistman/mkAlias/ab1afe594a3da8be30814b735cc5ad53d7c326f7";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # nixpkgs unstable channel
    # 2024-02-28
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/807e9154dcb16384b1b765ebe9cd2bba2ac287fd";
    
    # specific nixpkgs version for compatibility
    # 2024-02-10
    nixpkgs-locked.url = "github:NixOS/nixpkgs/1042fd8b148a9105f3c0aca3a6177fd1d9360ba5";

    # personal nix-home-manager config
    # 2024-01-23
    nix-home-manager.url = "path:./nix-home-manager";
    
    # personal dotfiles
    # 2024-01-30
    dotfiles.url = "path:./dotfiles";
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
