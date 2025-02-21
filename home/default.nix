{ config, inputs, pkgs, lib, ... }:

let dotfiles = inputs.dotfiles;
in {

  # moar https://github.com/yuanw/nix-home/blob/main/modules/macintosh.nix

  # import sub modules
  imports = [
    ./link-home-manager-installed-apps.nix
    ./docker.nix
    ./gw.nix
    #./gpg.nix
    #./fonts.nix
    (inputs.nix-home-manager + "/modules")
  ];

  #programs.t-firefox = {
  #  enable = true;
  #  package = pkgs.firefox-devedition-bin;
  #  extraEngines = (import ./firefox-da.nix { engine= "google"; });
  #};
  programs.t-doomemacs.enable = true;
  programs.t-nvim.enable = true;
  programs.t-terminal.alacritty = {
    enable = true;
    package = pkgs.unstable.alacritty;
  };
  programs.t-tmux.enable = true;
  programs.t-zoxide.enable = true;
  programs.t-shell-tooling.enable = true;
  programs.t-git = {
    enable = true;
    # gh version >2.40.0
    # https://github.com/cli/cli/issues/326
    ghPackage = pkgs.unstable.gh;
  };

  # 启用 1Password 核心功能
 # programs._1password.enable = true;
 # programs._1password-gui.enable = true;
 # programs._1password-gui.polkitPolicyOwners = [ "jqwang" ]; # 替换为你的用户名

  # home manager needs this
  home = {
    username = "jqwang";
    homeDirectory = lib.mkForce "/Users/jqwang";
    stateVersion = "23.11";
  };

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/darwin/
  home.packages = with pkgs; [
    coreutils
    openconnect
    #ollama
    pkgs.unstable.yabai
    pkgs.unstable.skhd
    tree      # 目录树显示
    jq        # JSON 处理
    fzf       # 模糊搜索
    bat       # 代码高亮查看
    #open-webui
  ];

  # TODO hardware.keyboard.zsa.enable

  home.file = {
    ".config/dotfiles".source = dotfiles;
    ".config/dotfiles".onChange = ''
      echo "Fixing swiftbar path"
      /usr/bin/defaults write com.ameba.Swiftbar PluginDirectory \
        $(/etc/profiles/per-user/jqwang/bin/readlink ~/.config/dotfiles)/swiftbar/scripts
      echo swiftbar plugin directory is $(/usr/bin/defaults read com.ameba.Swiftbar PluginDirectory)
    '';

    "Library/KeyBindings/DefaultKeyBinding.dict".source = dotfiles
      + "/DefaultKeyBinding.dict";

    ".ideavimrc".source = dotfiles + "/ideavimrc";

    ".yabairc".source = dotfiles + "/yabairc";
    ".yabairc".onChange =
      "/etc/profiles/per-user/jqwang/bin/yabai --restart-service";

    ".skhdrc".source = dotfiles + "/skhdrc";
    ".skhdrc".onChange =
      "/etc/profiles/per-user/jqwang/bin/skhd --restart-service";
  };

  # 建议添加 shell 配置
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
  };
}
