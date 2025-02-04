{ inputs, pkgs, ... }: {

  environment.extraInit = ''
    export PATH=$HOME/bin:/opt/homebrew/bin:/opt/homebrew/anaconda3/bin:$PATH
    export PATH="$PATH:/Users/jqwang/.lmstudio/bin"
    export USER_EMAIL="jiaqiwang969@gmail.com"                        
    export USER_EMAIL_2="jiaqi_wang@sjtu.com"
  '';

  # install packages from nix's official package repository.
  environment.systemPackages = with pkgs; [
    git
    nil # nix language server
    nixfmt # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt#examples
    btop    # 系统监控
    bottom  # 系统监控
    nload   # 网络监控
    htop      # 系统监控
    iftop     # 网络监控
    duf       # 磁盘使用分析
    fd        # 文件搜索
    ripgrep   # 文本搜索
  ];

  # To make this work, homebrew need to be installed manually, see
  # https://brew.sh The apps installed by homebrew are not managed by nix, and
  # not reproducible!  But on macOS, homebrew has a much larger selection of
  # apps than nixpkgs, especially for GUI apps!

  # work mac comes with brew
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [ "CtrlSpice/homebrew-otel-desktop-viewer" ];

    # brew install
    brews = [ "otel-desktop-viewer" "ollama"];

    # brew install --cask
    # these need to be updated manually
    casks = [
      # 开发工具
      "swiftbar"
      "intellij-idea"
      
      # 多媒体
      "spotify"
      
      # 通讯工具
      "zoom"
      
      # 科学计算
      "anaconda"
    ];

    # mac app store
    # click
    masApps = {
      #amphetamine = 937984704;
      #kindle = 302584613;
      #tailscale = 1475387142;

      # useful for debugging macos key codes
      #key-codes = 414568915;
    };
  };
}
