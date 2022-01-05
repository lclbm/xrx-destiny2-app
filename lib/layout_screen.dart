import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xrx/drawer_screen.dart';
import 'package:xrx/home_screen.dart';
import 'package:xrx/manifest/manifest.service.dart';
import 'package:xrx/storage/storage.service.dart';
import 'package:xrx/widget/download_manifest_widget.dart';
import 'package:xrx/widget/select_language_widget.dart';

class LayoutScreen extends StatefulWidget {
  final ManifestService manifest = new ManifestService();

  @override
  _LayoutScreenState createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final Duration duration = Duration(milliseconds: 200);
  Widget currentContent = Container();

  @override
  void initState() {
    _controller = AnimationController(duration: duration, vsync: this);
    super.initState();
    initLoading();
  }

  void initLoading() async {
    await StorageService.init();
    checkLanguage();
  }

  Future checkLanguage() async {
    String selectedLanguage = StorageService.getLanguage();
    bool hasSelectedLanguage = selectedLanguage != null;
    if (hasSelectedLanguage) {
      checkManifest();
    } else {
      showSelectLanguage();
    }
  }

  showSelectLanguage() async {
    List<String> availableLanguages =
        await widget.manifest.getAvailableLanguages();
    SelectLanguageWidget childWidget = SelectLanguageWidget(
      availableLanguages: {'zh-chs': '简体中文', 'zh-cht': '繁体中文'},
      onChange: (language) {},
      onSelect: (language) {
        this.checkManifest();
      },
    );
    this.changeContent(childWidget);
  }

  showDownloadManifest() async {
    String language = StorageService.getLanguage();
    DownloadManifestWidget screen = DownloadManifestWidget(
      selectedLanguage: language,
      onFinish: () {
        everythingIsOk();
      },
    );
    this.changeContent(screen);
  }

  checkManifest() async {
    try {
      bool needsUpdate = await widget.manifest.needsUpdate();
      if (needsUpdate) {
        showDownloadManifest();
      } else {
        everythingIsOk();
      }
    } catch (e) {
      print(e);
      this.changeContent(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text("无法连接至Bungie服务器，请检查你的网络连接后再试。"),
          ),
          ElevatedButton(
            onPressed: () {
              changeContent(null);
              checkManifest();
            },
            child: Text("重试"),
          ),
          ElevatedButton(
            onPressed: () {
              exit(0);
            },
            style:
                ElevatedButton.styleFrom(primary: Theme.of(context).errorColor),
            child: Text("退出"),
          )
        ],
      ));
    }
  }

  void changeContent(Widget _) {
    setState(() {
      currentContent = _;
    });
  }

  void everythingIsOk() {
    changeContent(
      Stack(
        children: [
          DrawerScreen(
            controller: _controller,
          ),
          HomeScreen(
            controller: _controller,
            duration: duration,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: currentContent);
  }
}
