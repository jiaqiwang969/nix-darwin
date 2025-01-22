{ ... }:

let
  hostname = "JQdeMacBook-Pro";
  username = "jqwang";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };
}
