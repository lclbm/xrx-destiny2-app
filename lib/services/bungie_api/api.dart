import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/api/settings.dart';
import 'package:bungie_api/api/user.dart';
import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:bungie_api/enums/destiny_vendor_filter.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:bungie_api/models/destiny_equip_item_result.dart';
import 'package:bungie_api/models/destiny_item_action_request.dart';
import 'package:bungie_api/models/destiny_item_set_action_request.dart';
import 'package:bungie_api/models/destiny_item_state_request.dart';
import 'package:bungie_api/models/destiny_item_transfer_request.dart';
import 'package:bungie_api/models/destiny_postmaster_transfer_request.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:bungie_api/models/destiny_vendors_response.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:bungie_api/responses/destiny_profile_response_response.dart';
import 'package:bungie_api/responses/destiny_vendors_response_response.dart';
import 'package:bungie_api/responses/int32_response.dart';
import 'package:bungie_api/responses/user_membership_data_response.dart';

class BungieApiService {
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";
  static const String apiKey = "19a8efe4509a4570bee47bd9883f7d93";

  static String parseUrl(String url) => '$baseUrl$url';

  static Future<DestinyManifestResponse> getManifest() async {
    return await Destiny2.getDestinyManifest(new Client());
  }

  static Future<DestinyProfileResponse?> getProfile(
    List<DestinyComponentType> components,
    String membershipId,
    BungieMembershipType membershipType,
  ) async {
    DestinyProfileResponseResponse response = await Destiny2.getProfile(
        Client(), components, membershipId, membershipType);
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
      'X-API-Key': BungieApiService.apiKey,
      'Accept': 'application/json'
    };
    if (config.bodyContentType != null) {
      headers['Content-Type'] = config.bodyContentType!;
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
        if (paramsString.length == 0) {
          paramsString += "?";
        } else {
          paramsString += "&";
        }
        paramsString += "$name=$valueStr";
      });
    }

    late io.HttpClientResponse response;
    io.HttpClient client = io.HttpClient();

    if (config.method == 'GET') {
      var req = await client.getUrl(
          Uri.parse("${BungieApiService.apiUrl}${config.url}$paramsString"));
      headers.forEach((name, value) {
        req.headers.add(name, value);
      });
      response = await req.close().timeout(Duration(seconds: 12));
    }

    dynamic json;
    try {
      var stream = response.transform(Utf8Decoder());
      var text = "";
      await for (var t in stream) {
        text += t;
      }
      json = jsonDecode(text ?? "{}");
    } catch (e) {
      json = {};
    }

    return HttpResponse(json, response.statusCode);
  }
}
