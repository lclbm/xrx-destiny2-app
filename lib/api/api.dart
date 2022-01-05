import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_activity_mode_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:bungie_api/enums/destiny_stats_group_type.dart';
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/models/destiny_activity_history_results.dart';
import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:bungie_api/models/destiny_post_game_carnage_report_data.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:bungie_api/responses/destiny_profile_response_response.dart';
import 'package:bungie_api/src/models/destiny_historical_stats_account_result.dart';

class BungieApi {
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";
  static const String apiKey = "19a8efe4509a4570bee47bd9883f7d93";

  static String parseUrl(String url) => '$baseUrl$url';

  static Future<DestinyManifest> getManifest() async {
    var response = await Destiny2.getDestinyManifest(new Client());
    return response.response;
  }

  static Future<DestinyProfileResponse> getProfile(
    List<DestinyComponentType> components,
    String membershipId,
    BungieMembershipType membershipType,
  ) async {
    DestinyProfileResponseResponse response = await Destiny2.getProfile(
        Client(), components, membershipId, membershipType);
    return response.response;
  }

  static Future<List<UserInfoCard>> searchDestinyPlayer(
    String displayName,
    BungieMembershipType membershipType,
  ) async {
    var response = await Destiny2.searchDestinyPlayer(
        Client(), displayName, membershipType);
    return response.response;
  }

  static Future<DestinyActivityHistoryResults> getActivityHistory(
    String characterId,
    int count,
    String membershipId,
    BungieMembershipType membershipType,
    DestinyActivityModeType mode,
    int page,
  ) async {
    var response = await Destiny2.getActivityHistory(
        Client(), characterId, count, membershipId, membershipType, mode, page);
    return response.response;
  }

  static Future<DestinyPostGameCarnageReportData> getPostGameCarnageReport(
    String activityId,
  ) async {
    var response =
        await Destiny2.getPostGameCarnageReport(Client(), activityId);
    return response.response;
  }

  static Future<DestinyHistoricalStatsAccountResult>
      getHistoricalStatsForAccount(
    String destinyMembershipId,
    List<DestinyStatsGroupType> groups,
    BungieMembershipType membershipType,
  ) async {
    var response = await Destiny2.getHistoricalStatsForAccount(
        Client(), destinyMembershipId, groups, membershipType);
    return response.response;
  }
}

class Client implements HttpClient {
  @override
  Future<HttpResponse> request(HttpClientConfig config) async {
    var req = await _request(config);
    return req;
  }

  Future<HttpResponse> _request(HttpClientConfig config) async {
    Map<String, String> headers = {
      'X-API-Key': BungieApi.apiKey,
      'Accept': 'application/json'
    };
    if (config.bodyContentType != null) {
      headers['Content-Type'] = config.bodyContentType;
    }
    String paramsString = "";
    if (config.params != null) {
      config.params?.forEach((name, value) {
        String valueStr = '';
        if (value is String) {
          valueStr = value;
        }
        if (value is num) {
          valueStr = "$value";
        }
        if (value is List) {
          valueStr = value.join(',');
        }
        if (paramsString.isEmpty) {
          paramsString += "?";
        } else {
          paramsString += "&";
        }
        paramsString += "$name=$valueStr";
      });
    }

    io.HttpClientResponse response;
    io.HttpClient client = io.HttpClient();

    if (config.method == 'GET') {
      var a = Uri.parse("${BungieApi.apiUrl}${config.url}$paramsString");
      var req = await client.getUrl(a);
      headers.forEach((name, value) {
        req.headers.add(name, value);
      });
      response = await req.close().timeout(Duration(seconds: 12));
    }

    dynamic json;
    try {
      var stream = response.transform(Utf8Decoder());
      String text = '';
      await for (var t in stream) {
        text += t;
      }
      json = jsonDecode(text.isNotEmpty ? text : "{}");
    } catch (e) {
      json = {};
    }

    return HttpResponse(json, response.statusCode);
  }
}
