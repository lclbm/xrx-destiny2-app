import 'package:bungie_api/enums/destiny_activity_mode_type.dart';
import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_activity_mode_definition.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_historical_stats_period_group.dart';
import 'package:bungie_api/models/destiny_profile_component.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:frefresh/frefresh.dart';
import 'package:xrx/Utils.dart';
import 'package:xrx/api/api.dart';
import 'package:xrx/manifest/manifest.service.dart';

class ActivityDetail {
  final DestinyHistoricalStatsPeriodGroup activity;
  final DestinyActivityDefinition directorInfo;
  final DestinyActivityDefinition referenceInfo;
  final List<String> iconList;
  ActivityDetail(
      this.activity, this.directorInfo, this.referenceInfo, this.iconList);
}

class ActivityQueryWidget extends StatefulWidget {
  final manifest = ManifestService();
  final DestinyProfileResponse profileResponse;

  ActivityQueryWidget({Key key, this.profileResponse}) : super(key: key);

  @override
  _ActivityQueryWidgetState createState() => _ActivityQueryWidgetState();
}

class _ActivityQueryWidgetState extends State<ActivityQueryWidget>
    with TickerProviderStateMixin {
  final FRefreshController _controller = FRefreshController();
  final ScrollController _scrollController = ScrollController();
  DestinyProfileResponse _profileResponse;
  DestinyProfileComponent _profile;
  Map<String, DestinyCharacterComponent> _characters;

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
          child: ListView.builder(
            controller: _scrollController,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (c, i) => SingleListItemWidget(
              activityDetail: _activityDetails[i],
              openedIndexList: _openedIndexList,
              index: i,
            ),
            itemCount: _activityDetails.length,
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoading,
        ));
  }
}

class SingleListItemWidget extends StatefulWidget {
  final ActivityDetail activityDetail;
  final List<bool> openedIndexList;
  final int index;

  const SingleListItemWidget(
      {Key key, this.activityDetail, this.openedIndexList, this.index})
      : super(key: key);

  @override
  _SingleListItemWidgetState createState() => _SingleListItemWidgetState();
}

class _SingleListItemWidgetState extends State<SingleListItemWidget> {
  int _index;
  List<bool> _openedIndexList;
  bool _opened = false;
  DestinyHistoricalStatsPeriodGroup _activity;
  DestinyActivityDefinition _directorInfo;
  DestinyActivityDefinition _referenceInfo;
  List<String> _iconList;

  bool get isOpened => _opened;
  set isOpened(bool _) {
    if (isOpened) {
      _opened = false;
      _openedIndexList[_index] = false;
      setState(() {});
    } else {}
  }

  @override
  void initState() {
    _index = this.widget.index;
    _openedIndexList = this.widget.openedIndexList;
    _activity = this.widget.activityDetail.activity;
    _directorInfo = this.widget.activityDetail.directorInfo;
    _referenceInfo = this.widget.activityDetail.referenceInfo;
    _iconList = this.widget.activityDetail.iconList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isOpened = !isOpened;
      },
      child: AnimatedContainer(
        height: isOpened ? 100.0 + 2 : 50.0 + 2,
        duration: Duration(milliseconds: 500),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        curve: Curves.ease,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: new Border.all(color: Colors.black26, width: 1),
        ),
        onEnd: () {},
        child: Column(
          children: [
            Container(
              height: 50,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  CachedNetworkImage(
                      color: Colors.blueAccent,
                      width: 40,
                      height: 40,
                      imageUrl: _iconList.isNotEmpty
                          ? Utils.urlPrase(_iconList.first)
                          : Utils.missingIcoUrl),
                  SizedBox(width: 20),
                  SizedBox(
                      width: 110,
                      child: Text(
                        _directorInfo.displayProperties?.name ??
                            'something wrong',
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
            if (isOpened)
              Container(height: 50, child: Center(child: Text('测试'))),
          ],
        ),
      ),
    );
  }
}
