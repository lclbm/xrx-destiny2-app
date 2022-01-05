import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xrx/api/api.dart';
import 'package:xrx/membership_provider.dart';

class DrawerScreen extends StatefulWidget {
  final AnimationController controller;

  const DrawerScreen({Key key, this.controller}) : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  Animation<double> _scaleAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MembershipNotifier _provider =
        Provider.of<MembershipNotifier>(context, listen: false);
    MembershipNotifier _consumer = Provider.of<MembershipNotifier>(context);

    if (_scaleAnimation == null) {
      _scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
          CurvedAnimation(parent: widget.controller, curve: Curves.ease));
    }

    if (_slideAnimation == null) {
      _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
          .animate(
              CurvedAnimation(parent: widget.controller, curve: Curves.ease));
    }
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          color: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(children: [
            SizedBox(height: 30),
            Row(children: [
              GestureDetector(
                onTap: () async {
                  _provider.profileResponse = await BungieApi.getProfile([
                    DestinyComponentType.Profiles,
                    DestinyComponentType.Characters,
                    DestinyComponentType.ProfileProgression
                  ], '4611686018489755635', BungieMembershipType.TigerSteam);
                },
                child: CircleAvatar(
                  backgroundImage: _consumer.isPlayerSelector
                      ? CachedNetworkImageProvider(_consumer.emblemUrl)
                      : null,
                  radius: 30,
                ),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 130, maxWidth: 180),
                    child: Text('${_consumer.playerName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 6),
                  Text('赛季等级：${_consumer.seasonLevel}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('上次在线于：${_consumer.lastTimePlayed}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                          icon: Icon(Icons.favorite_outline),
                          onPressed: () {},
                          color: Colors.white,
                        ),
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                          icon: Icon(Icons.manage_search_outlined),
                          onPressed: () {},
                          color: Colors.white,
                        ),
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                          icon: Icon(Icons.logout_outlined),
                          onPressed: () {
                            _provider.clear();
                          },
                          color: Colors.white,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ]),
            SizedBox(height: 30),
            ListTile(
                leading: Icon(Icons.home, color: Colors.white, size: 28),
                title: Text('首页',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(horizontal: 8)),
            ListTile(
                leading: Icon(Icons.list, color: Colors.white, size: 28),
                title: Text('数据库',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(horizontal: 8)),
            ListTile(
                leading: Icon(Icons.settings, color: Colors.white, size: 28),
                title: Text('设置',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(horizontal: 8)),
            ListTile(
                leading: Icon(Icons.info, color: Colors.white, size: 28),
                title: Text('关于',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(horizontal: 8))
          ]),
        ),
      ),
    );
  }
}

class PlayerSearchWidget extends StatefulWidget {
  @override
  _PlayerSearchWidgetState createState() => _PlayerSearchWidgetState();
}

class _PlayerSearchWidgetState extends State<PlayerSearchWidget> {
  bool isPlayerSelected = false;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [],
    );
  }
}
