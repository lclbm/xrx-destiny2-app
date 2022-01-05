import 'dart:async';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_activity_mode_type.dart';
import 'package:bungie_api/models/destiny_activity_history_results.dart';
import 'package:bungie_api/models/destiny_historical_stats_per_character.dart';
import 'package:bungie_api/models/destiny_historical_stats_period_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:provider/provider.dart';
import 'package:xrx/Utils.dart';
import 'package:xrx/api/api.dart';
import 'package:xrx/membership_provider.dart';

class CareerQueryWidger extends StatefulWidget {
  const CareerQueryWidger({Key key}) : super(key: key);

  @override
  _CareerQueryWidgerState createState() => _CareerQueryWidgerState();
}

class _CareerQueryWidgerState extends State<CareerQueryWidger> {
  MembershipNotifier _consumer;
  String _membershipId;
  BungieMembershipType _membershipType;

  Map<DateTime, int> _timeSpendperDay = {};
  Map<DateTime, List<DestinyHistoricalStatsPeriodGroup>> _activitiesperDay = {};
  int _activitiesCount = 0;
  int _charactersCount = 0;
  int _charactersDoneCount = 0;
  List<DestinyHistoricalStatsPerCharacter> _characters;

  StreamController<List<int>> _dataController =
      StreamController<List<int>>.broadcast();

  StreamSink<List<int>> get _dataSink => _dataController.sink;
  Stream<List<int>> get _dataStream => _dataController.stream;

  Future getCareerTimeCost() async {
    var _ = await BungieApi.getHistoricalStatsForAccount(
        _consumer.membershipId, [], _consumer.membershipType);
    _characters = _.characters;
    _charactersCount = _characters.length;

    for (var chatacter in _characters) {
      var page = 0;
      var count = 250;
      while (true) {
        DestinyActivityHistoryResults _;
        try {
          _ = await BungieApi.getActivityHistory(
              chatacter.characterId,
              count,
              _membershipId,
              _membershipType,
              DestinyActivityModeType.None,
              page);
        } catch (e) {
          print('network error');
          continue;
        }

        if (_.activities != null)
          _.activities.forEach((activity) {
            var period = Utils.getBungieTimeFromStr(activity.period);
            var seconds = activity.values["timePlayedSeconds"].basic.value;
            var newDate = DateTime(period.year, period.month, period.day);
            if (!(_timeSpendperDay.containsKey(newDate)))
              _timeSpendperDay[newDate] = 0;
            _timeSpendperDay[newDate] += seconds.toInt();
            if (!(_activitiesperDay.containsKey(newDate)))
              _activitiesperDay[newDate] = [];
            _activitiesperDay[newDate].add(activity);
          });
        _activitiesCount += _.activities?.length ?? 0;
        page++;
        _dataSink
            .add([_charactersDoneCount, _charactersCount, _activitiesCount]);
        if (_.activities == null || _.activities.length < 250) {
          _charactersDoneCount++;
          break;
        }
      }
    }
  }

  Future getCareerTimeCost_() async {
    var _ = await BungieApi.getHistoricalStatsForAccount(
        _consumer.membershipId, [], _consumer.membershipType);
    _characters = _.characters;
    _charactersCount = _characters.length;

    for (var chatacter in _characters) {
      var page = 0;
      var count = 250;
      var _ = await BungieApi.getActivityHistory(chatacter.characterId, count,
          _membershipId, _membershipType, DestinyActivityModeType.None, page);
      if (_.activities != null)
        _.activities.forEach((activity) {
          var period = Utils.getBungieTimeFromStr(activity.period);
          var seconds = activity.values["timePlayedSeconds"].basic.value;
          var newDate = DateTime(period.year, period.month, period.day);
          if (!(_timeSpendperDay.containsKey(newDate)))
            _timeSpendperDay[newDate] = 0;
          _timeSpendperDay[newDate] += seconds.toInt();
          if (!(_activitiesperDay.containsKey(newDate)))
            _activitiesperDay[newDate] = [];
          _activitiesperDay[newDate].add(activity);
        });
      _activitiesCount += _.activities?.length ?? 0;

      break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _consumer = Provider.of<MembershipNotifier>(context);
    _membershipId = _consumer.membershipId;
    _membershipType = _consumer.membershipType;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('热力图查询'),
        ),
        body: Column(
          children: [
            SizedBox(height: 15),
            FutureBuilder(
                builder: (ctx, snapShop) {
                  switch (snapShop.connectionState) {
                    case ConnectionState.done:
                      var datasets = _timeSpendperDay.map((key, value) =>
                          MapEntry(key, (value / 3600).round()));
                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          children: [
                            HeatMapCalendar(
                              size: 30,
                              showColorTip: false,
                              textColor: Colors.black87,
                              defaultColor: Colors.white,
                              flexible: true,
                              colorMode: ColorMode.opacity,
                              datasets: datasets,
                              colorsets: const {1: Colors.red},
                              onClick: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(value.toString())));
                              },
                            ),
                            SizedBox(height: 30),
                            HeatMap(
                              showColorTip: false,
                              datasets: datasets,
                              colorMode: ColorMode.opacity,
                              showText: true,
                              scrollable: true,
                              colorsets: {1: Colors.greenAccent.shade700},
                              onClick: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(value.toString())));
                              },
                            )
                          ],
                        ),
                      );
                    default:
                      return Container(
                          child: Column(
                        children: [
                          SizedBox(height: 30),
                          CircularProgressIndicator(),
                          SizedBox(height: 40),
                          StreamBuilder<List<int>>(
                              stream: _dataStream,
                              initialData: [0, 0, 0],
                              builder: (context, snapshot) {
                                var data = snapshot.data;
                                return Center(
                                  child: Column(children: [
                                    Text('获取角色战绩:  ${data[0]}/${data[1]}'),
                                    SizedBox(height: 20),
                                    Text('当前已获取${data[2]}场战绩')
                                  ]),
                                );
                              }),
                        ],
                      ));
                  }
                },
                future: getCareerTimeCost()),
          ],
        ));
  }
}
