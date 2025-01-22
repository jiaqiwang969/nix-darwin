{ engine, ... }:
{
  # 使用 engine 参数
  search = {
    default = engine;
    engines = {
      google = {
        urls = [{ template = "https://www.google.com/search?q={searchTerms}"; }];
        icon = "https://www.google.com/favicon.ico";
        definedAliases = [ "@g" ];
      };
    };
  };
}
