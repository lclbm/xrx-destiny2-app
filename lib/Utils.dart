class Utils {
  static String missingIcoUrl =
      'https://www.bungie.net/common/destiny2_content/icons/DestinyActivityModeDefinition_234e7e18549d5eae2ddb012f2bcb203a.png';

  static int getSeasonLevelFromProgress(int currentProgress) =>
      currentProgress ~/ 100000 + 1;

  static String urlPrase(String url) => 'https://www.bungie.net$url';

  static DateTime getBungieTimeFromStr(String timeStr) {
    return DateTime.parse(timeStr).toLocal();
  }

  static String getTimeDiffStr(dynamic preTime) {
    DateTime now = DateTime.now();
    if (preTime is DateTime) {}
    if (preTime is String) {
      preTime = getBungieTimeFromStr(preTime);
    }
    var diff = now.difference(preTime);
    int ds = diff.inDays;
    int hs = diff.inHours;
    int ms = diff.inMinutes;
    if (ds >= 360)
      return '${ds ~/ 360}年前';
    else if (ds >= 30)
      return '${ds ~/ 30}月前';
    else if (ds > 0)
      return '$ds天前';
    else if (hs > 0)
      return '$hs小时前';
    else if (ms > 0)
      return '$ms分钟前';
    else
      return '刚刚';
  }
}
