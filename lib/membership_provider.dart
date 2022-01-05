import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/models/destiny_profile_component.dart';
import 'package:flutter/material.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:xrx/Utils.dart';

class MembershipNotifier with ChangeNotifier {
  DestinyProfileResponse _profileResponse;
  BungieMembershipType _membershipType;
  String _membershipId;
  String _lastTimePlayed;
  String _playerName = '请先选择需要查询的玩家';
  String _emblemUrl;
  int _seasonLevel;
  bool _isPlayerSelector = false;

  BungieMembershipType get membershipType => _membershipType;
  String get membershipId => _membershipId;
  bool get isPlayerSelector => _isPlayerSelector;
  String get lastTimePlayed => _lastTimePlayed;
  String get playerName => _playerName;
  String get emblemUrl => _emblemUrl;
  int get seasonLevel => _seasonLevel;

  DestinyProfileResponse get profileResponse => _profileResponse;

  void clear() {
    _profileResponse = null;
    _membershipType = null;
    _membershipId = null;
    _lastTimePlayed = null;
    _playerName = '请先选择需要查询的玩家';
    _emblemUrl = null;
    _seasonLevel = null;
    _isPlayerSelector = false;
    notifyListeners();
  }

  set profileResponse(DestinyProfileResponse profileResponse) {
    _profileResponse = profileResponse;
    var profileData = profileResponse.profile.data;
    var charactersData = profileResponse.characters.data;
    var profileProgressionData = profileResponse.profileProgression.data;
    _membershipType = profileData.userInfo.membershipType;
    _membershipId = profileData.userInfo.membershipId;
    _lastTimePlayed = Utils.getTimeDiffStr(profileData.dateLastPlayed);
    _playerName = profileData.userInfo.bungieGlobalDisplayName +
        '#' +
        profileData.userInfo.bungieGlobalDisplayNameCode.toString();
    _emblemUrl = Utils.urlPrase(charactersData.values.first.emblemPath);
    _seasonLevel = Utils.getSeasonLevelFromProgress(profileProgressionData
        .seasonalArtifact.powerBonusProgression.currentProgress);
    _isPlayerSelector = true;
    notifyListeners();
  }
}
