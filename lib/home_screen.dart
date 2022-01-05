import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xrx/api/api.dart';
import 'package:xrx/membership_provider.dart';
import 'package:xrx/storage/storage.service.dart';
import 'package:xrx/widget/query_activity_widget.dart';
import 'package:xrx/widget/query_career_widget.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage = new StorageService();
  final AnimationController controller;
  final Duration duration;

  HomeScreen({Key key, this.controller, this.duration}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool initFlag = false;
  bool _menuOpen = false;
  bool _folded = true;
  String _displayName = '何志武223#5270';
  String _membershipId = '4611686018497181967';
  BungieMembershipType _membershipType = BungieMembershipType.TigerSteam;
  Animation<double> _scaleAnimation;

  MembershipNotifier _provider;
  MembershipNotifier _consumer;
  Widget _currentContent;

  void unfocusOnTextField() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void changeContent([Widget content]) {
    setState(() {
      _currentContent = content;
    });
  }

  Widget headShowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(_consumer.emblemUrl),
          radius: 20,
        ),
        SizedBox(width: 10),
        Text(
          _consumer.playerName,
          style: TextStyle(
              fontSize: 14,
              color: Colors.blueAccent.shade700,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.fade),
        ),
      ],
    );
  }

  Widget headQueryWidget() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      width: _folded ? 50 : 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: kElevationToShadow[6]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: TextField(
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 18, bottom: 6),
                hintText: 'BungieId',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none),
            onChanged: (value) {
              _displayName = value;
            },
            onSubmitted: (value) async {
              var _ = await BungieApi.searchDestinyPlayer(
                  Uri.encodeComponent(_displayName),
                  BungieMembershipType.TigerSteam);
              if (_.length == 1) {
                var membershipType = _[0].membershipType;
                var membershipId = _[0].membershipId;
                this
                    .widget
                    .storage
                    .setString(StorageKeys.membershipId, membershipId);
                this
                    .widget
                    .storage
                    .setInt(StorageKeys.membershipType, membershipType.index);
                _provider.profileResponse = await BungieApi.getProfile([
                  DestinyComponentType.Profiles,
                  DestinyComponentType.Characters,
                  DestinyComponentType.ProfileProgression
                ], membershipId, membershipType);
              }

              unfocusOnTextField();
            },
          )),
          IconButton(
              onPressed: () async {
                if (!_folded) {
                  var _ = await BungieApi.searchDestinyPlayer(
                      Uri.encodeComponent(_displayName),
                      BungieMembershipType.TigerSteam);
                  if (_.length == 1) {
                    var membershipType = _[0].membershipType;
                    var membershipId = _[0].membershipId;
                    this
                        .widget
                        .storage
                        .setString(StorageKeys.membershipId, membershipId);
                    this.widget.storage.setInt(
                        StorageKeys.membershipType, membershipType.index);
                    _provider.profileResponse = await BungieApi.getProfile([
                      DestinyComponentType.Profiles,
                      DestinyComponentType.Characters,
                      DestinyComponentType.ProfileProgression
                    ], membershipId, membershipType);
                  }

                  unfocusOnTextField();
                } else
                  setState(() {
                    _folded = !_folded;
                  });
              },
              icon: Icon(Icons.search))
        ],
      ),
    );
  }

  void queryShow(String title, [Widget _]) {
    changeContent(_);
  }

  Future initMembershipData(String membershipId, int membershipType) async {
    if (membershipId != null) {
      BungieMembershipType membershipType_;
      switch (membershipType) {
        case 1:
          membershipType_ = BungieMembershipType.TigerXbox;
          break;
        case 2:
          membershipType_ = BungieMembershipType.TigerPsn;
          break;
        case 3:
          membershipType_ = BungieMembershipType.TigerSteam;
          break;
      }
      _provider.profileResponse = await BungieApi.getProfile([
        DestinyComponentType.Profiles,
        DestinyComponentType.Characters,
        DestinyComponentType.ProfileProgression
      ], membershipId, membershipType_);
    }
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<MembershipNotifier>(context, listen: false);
    _consumer = Provider.of<MembershipNotifier>(context);
    var membershipId = this.widget.storage.getString(StorageKeys.membershipId);
    var membershipType = this.widget.storage.getInt(StorageKeys.membershipType);
    if (initFlag == false) {
      initMembershipData(membershipId, membershipType);
      initFlag = true;
    }
    if (_scaleAnimation == null) {
      _scaleAnimation = Tween<double>(begin: 1, end: 0.7).animate(
          CurvedAnimation(parent: widget.controller, curve: Curves.ease));
    }
    var size = MediaQuery.of(context).size;

    return _currentContent != null
        ? _currentContent
        : AnimatedPositioned(
            duration: widget.duration,
            top: 0,
            bottom: 0,
            left: _menuOpen ? 0.3 * size.width : 0,
            right: _menuOpen ? -0.4 * size.width : 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (_menuOpen)
                    setState(() {
                      widget.controller.reverse();
                      _menuOpen = false;
                    });
                },
                onPanUpdate: (details) {
                  unfocusOnTextField();
                  double dx = details.delta.dx;
                  if (dx < 0 && _menuOpen)
                    setState(() {
                      widget.controller.reverse();
                      _menuOpen = false;
                    });
                  if (dx > 0 && !_menuOpen)
                    setState(() {
                      widget.controller.forward();
                      _menuOpen = true;
                    });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: AbsorbPointer(
                    absorbing: _menuOpen ? true : false,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          height: 50,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: !_menuOpen
                                    ? IconButton(
                                        icon: Icon(Icons.menu),
                                        onPressed: () {
                                          unfocusOnTextField();
                                          setState(() {
                                            widget.controller.forward();
                                            _menuOpen = true;
                                          });
                                        },
                                        color: Colors.blueAccent,
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.arrow_back_ios),
                                        onPressed: () {
                                          unfocusOnTextField();
                                          setState(() {
                                            widget.controller.reverse();
                                            _menuOpen = false;
                                          });
                                        },
                                        color: Colors.blueAccent,
                                      ),
                              ),
                              Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                      height: 40,
                                      constraints: BoxConstraints(
                                          minWidth: 0, maxWidth: 200),
                                      child: _consumer.isPlayerSelector
                                          ? headShowWidget()
                                          : headQueryWidget())),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.notifications),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          // Create the SelectionScreen in the next step.
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ActivityQueryWidget(
                                                    profileResponse: _consumer
                                                        .profileResponse,
                                                  )));
                                    },
                                    color: Colors.blueAccent,
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 100),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  // Create the SelectionScreen in the next step.
                                  MaterialPageRoute(
                                      builder: (context) => ActivityQueryWidget(
                                            profileResponse:
                                                _consumer.profileResponse,
                                          )));
                            },
                            child: Text('战绩查询')),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  // Create the SelectionScreen in the next step.
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CareerQueryWidger()));
                            },
                            child: Text('热力图查询')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
