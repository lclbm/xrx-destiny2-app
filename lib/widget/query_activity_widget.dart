import 'package:bungie_api/enums/destiny_activity_mode_type.dart';
import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_activity_mode_definition.dart';
import 'package:bungie_api/models/destiny_historical_stats_period_group.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_post_game_carnage_report_data.dart';
import 'package:bungie_api/models/destiny_profile_component.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:frefresh/frefresh.dart';
import 'package:xrx/Utils.dart';
import 'package:xrx/api/api.dart';
import 'package:xrx/manifest/manifest.service.dart';

class ActivityQueryWidget extends StatefulWidget {
  var manifest = ManifestService();
  final DestinyProfileResponse profileResponse;

  ActivityQueryWidget({Key key, this.profileResponse}) : super(key: key);

  @override
  _ActivityQueryWidgetState createState() => _ActivityQueryWidgetState();
}

class ActivityDetail {
  final DestinyHistoricalStatsPeriodGroup activity;
  final DestinyActivityDefinition directorInfo;
  final DestinyActivityDefinition referenceInfo;
  final List<String> iconList;
  ActivityDetail(
      this.activity, this.directorInfo, this.referenceInfo, this.iconList);
}

class _ActivityQueryWidgetState extends State<ActivityQueryWidget>
    with TickerProviderStateMixin {
  final FRefreshController _controller = FRefreshController();
  final ScrollController _scrollController = ScrollController();
  DestinyProfileResponse _profileResponse;
  DestinyProfileComponent _profile;
  var _characters;

  String _characterId;
  DestinyActivityModeType _mode = DestinyActivityModeType.None;
  int _count = 50;
  int _page = 0;

  List<ActivityDetail> _activityDetails = [];
  List<bool> _openedIndexList = [];

  @override
  void initState() {
    super.initState();
    _profileResponse = this.widget.profileResponse;
    _characters = this.widget.profileResponse.characters.data;
    _profile = this.widget.profileResponse.profile.data;
    _characterId = _characters.keys.first;

    _onRefresh();
  }

  void getData() async {
    var _ = await BungieApi.getActivityHistory(
        _characterId,
        _count,
        _profile.userInfo.membershipId,
        _profile.userInfo.membershipType,
        _mode,
        _page);
    List<DestinyHistoricalStatsPeriodGroup> activities = _.activities;

    for (var activity in activities) {
      var iconList = <String>[];
      var directorInfo = await decodeActivityHash(
          activity.activityDetails.directorActivityHash);
      var referenceInfo =
          await decodeActivityHash(activity.activityDetails.referenceId);
      var activityModeHashes = <int>[];
      if (directorInfo.activityModeHashes != null)
        activityModeHashes.addAll(directorInfo.activityModeHashes);
      if (directorInfo.activityTypeHash != null)
        activityModeHashes.add(directorInfo.activityTypeHash);

      for (var hash in activityModeHashes) {
        try {
          var _ = await decodeActivityModeHash(hash);
          if (_.displayProperties.hasIcon) {
            iconList.add(_.displayProperties.icon);
          }
        } catch (e) {}
      }
      if (directorInfo.displayProperties.hasIcon)
        iconList.add(directorInfo.displayProperties.icon);

      _activityDetails
          .add(ActivityDetail(activity, directorInfo, referenceInfo, iconList));
      _openedIndexList.add(false);
    }
  }

  _onRefresh() async {
    _page = 0;
    _activityDetails = <ActivityDetail>[];
    _openedIndexList = [];
    if (mounted) setState(() {});
    await getData();
    if (mounted) setState(() {});
    _controller.finishRefresh();
  }

  _onLoading() async {
    _page++;
    print('loading');
    await getData();

    _controller.backOriginOnLoadFinish = true;
    if (mounted) setState(() {});
    _controller.finishLoad();
  }

  Future<DestinyActivityDefinition> decodeActivityHash(dynamic hash) async {
    if (hash == null) {
      return null;
    }

    return await this
        .widget
        .manifest
        .getDefinition<DestinyActivityDefinition>(hash);
  }

  Future<DestinyActivityModeDefinition> decodeActivityModeHash(int hash) async {
    return await this
        .widget
        .manifest
        .getDefinition<DestinyActivityModeDefinition>(hash);
  }

  @override
  Widget build(BuildContext context) {
    var text4 = '上划加载';
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('战绩查询'),
        ),
        body: FRefresh(
          controller: _controller,
          header: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator()),
          ),
          headerHeight: 40,
          footer: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator()),
                SizedBox(width: 20),
                Text('加载中')
              ],
            ),
          ),
          footerHeight: 40,
          // footerBuilder: (setter) {
          //   _controller.setOnStateChangedCallback((state) {
          //     setter(() {
          //       if (_controller.loadState == LoadState.PREPARING_LOAD) {
          //         text4 = "Release to load";
          //       } else if (_controller.loadState == LoadState.LOADING) {
          //         text4 = "Loading..";
          //       } else if (_controller.loadState == LoadState.FINISHING) {
          //         text4 = "Loading completed";
          //       } else {
          //         text4 = "上划加载";
          //       }
          //     });
          //   });
          //   return Container(
          //       height: 38,
          //       alignment: Alignment.center,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           SizedBox(
          //             width: 15,
          //             height: 15,
          //             child: CircularProgressIndicator(
          //               backgroundColor: Colors.blueAccent,
          //               valueColor: new AlwaysStoppedAnimation<Color>(
          //                   Colors.blueAccent),
          //               strokeWidth: 2.0,
          //             ),
          //           ),
          //           const SizedBox(width: 9.0),
          //           Text(
          //             text4,
          //             style: TextStyle(color: Colors.blueAccent),
          //           ),
          //         ],
          //       ));
          // },
          child: ListView.builder(
            controller: _scrollController,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (c, i) =>
                SingleListItemWidget(activityDetail: _activityDetails[i]),
            itemCount: _activityDetails.length,
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoading,
        ));
  }
}

class SingleListItemWidget extends StatefulWidget {
  var manifest = ManifestService();
  final ActivityDetail activityDetail;

  SingleListItemWidget({Key key, this.activityDetail}) : super(key: key);

  @override
  _SingleListItemWidgetState createState() => _SingleListItemWidgetState();
}

class _SingleListItemWidgetState extends State<SingleListItemWidget> {
  int _index;
  bool _opened = false;
  DestinyHistoricalStatsPeriodGroup _activity;
  DestinyActivityDefinition _directorInfo;
  DestinyActivityDefinition _referenceInfo;
  List<String> _iconList;
  String _activityId;

  Map<String, DestinyPostGameCarnageReportData> pgcrCache = {};

  bool get isOpened => _opened;
  bool get isCached => pgcrCache.containsKey(_activityId);

  set isOpened(bool _) {
    _opened = !_opened;
    setState(() {});
  }

  @override
  void initState() {
    _activity = this.widget.activityDetail.activity;
    _directorInfo = this.widget.activityDetail.directorInfo;
    _referenceInfo = this.widget.activityDetail.referenceInfo;
    _iconList = this.widget.activityDetail.iconList;
    _activityId = _activity.activityDetails.instanceId;
    super.initState();
  }

  Future<DestinyPostGameCarnageReportData> getActivityPgcr(
      String activityId) async {
    return isCached
        ? pgcrCache[activityId]
        : await BungieApi.getPostGameCarnageReport(activityId);
  }

  Future<DestinyInventoryItemDefinition> decodeItemHash(dynamic hash) async {
    if (hash == null) {
      return null;
    }

    return await this
        .widget
        .manifest
        .getDefinition<DestinyInventoryItemDefinition>(hash);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: new Border.all(color: Colors.black26, width: 1),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () {
            isOpened = !isOpened;
          },
          child: Container(
            child: Row(
              children: [
                SizedBox(width: 10),
                CachedNetworkImage(
                    color: Colors.blueAccent,
                    width: 50,
                    height: 50,
                    imageUrl: _iconList.isNotEmpty
                        ? Utils.urlPrase(_iconList.first)
                        : Utils.missingIcoUrl),
                SizedBox(width: 20),
                SizedBox(
                    width: 110,
                    child: Text(
                      _directorInfo.displayProperties?.name ?? 'bug',
                      overflow: TextOverflow.clip,
                    )),
                SizedBox(width: 20),
                SizedBox(
                    width: 150,
                    child: Text(
                      Utils.getTimeDiffStr(_activity.period),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.clip,
                    )),
              ],
            ),
          ),
        ),
        if (isOpened)
          FutureBuilder(
              future: getActivityPgcr(_activityId),
              builder: (ctx, snapShot) {
                switch (snapShot.connectionState) {
                  case ConnectionState.done:
                    DestinyPostGameCarnageReportData pgcrData = snapShot.data;
                    pgcrCache[_activityId] = pgcrData;
                    var widgets = <Widget>[];

                    pgcrData.entries.forEach((var a) {
                      var bungieGlobalDisplayName =
                          a.player.destinyUserInfo.bungieGlobalDisplayName;
                      var bungieGlobalDisplayNameCode =
                          a.player.destinyUserInfo.bungieGlobalDisplayNameCode;
                      var iconPath =
                          BungieApi.parseUrl(a.player.destinyUserInfo.iconPath);
                      for (var name in [
                        'weaponKillsGrenade',
                        'weaponKillsMelee',
                        'weaponKillsSuper',
                        'weaponKillsAbility'
                      ]) {}
                      var secondaryWidgets = <Widget>[];
                      if (a.extended.weapons != null) {
                        secondaryWidgets.add(Container(
                          padding: EdgeInsets.fromLTRB(40, 5, 0, 0),
                          child: Row(children: [
                            SizedBox(width: 30),
                            SizedBox(width: 10),
                            Container(
                              width: 140,
                              child: Text('武器'),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 30,
                              child: Text('击杀'),
                            ),
                            SizedBox(width: 10),
                            Container(
                              child: Text('精准率'),
                            ),
                          ]),
                        ));
                        a.extended.weapons.forEach((_) {
                          var values = _.values;
                          var _widget = Container(
                            padding: EdgeInsets.fromLTRB(40, 5, 0, 0),
                            child: FutureBuilder(
                              builder: (ctx, snapShot) {
                                switch (snapShot.connectionState) {
                                  case ConnectionState.done:
                                    DestinyInventoryItemDefinition weaponData =
                                        snapShot.data;
                                    return Row(children: [
                                      CachedNetworkImage(
                                          width: 30,
                                          height: 30,
                                          imageUrl: BungieApi.parseUrl(
                                              weaponData
                                                  .displayProperties.icon)),
                                      SizedBox(width: 10),
                                      Container(
                                        width: 140,
                                        child: Text(
                                            weaponData.displayProperties.name),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        width: 30,
                                        child: Text(values['uniqueWeaponKills']
                                            .basic
                                            .displayValue),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        width: 40,
                                        child: Text(values[
                                                "uniqueWeaponKillsPrecisionKills"]
                                            .basic
                                            .displayValue),
                                      ),
                                    ]);
                                  default:
                                    return SizedBox();
                                }
                              },
                              future: decodeItemHash(_.referenceId),
                            ),
                          );
                          secondaryWidgets.add(_widget);
                        });
                      }

                      var _ = Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            children: [
                              Row(children: [
                                CachedNetworkImage(
                                    width: 40, height: 40, imageUrl: iconPath),
                                SizedBox(width: 10),
                                Container(
                                    child: Text(
                                        "$bungieGlobalDisplayName#$bungieGlobalDisplayNameCode",
                                        maxLines: 2))
                              ]),
                              Container(
                                child: Column(
                                  children: secondaryWidgets,
                                ),
                              )
                            ],
                          ));
                      widgets.add(_);
                    });
                    return Container(
                      child: Column(children: widgets),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                    );

                  default:
                    return isCached
                        ? SizedBox()
                        : Container(
                            child: CircularProgressIndicator(),
                            margin: EdgeInsets.only(bottom: 10));
                }
              }),
      ]),
    );
  }
}
