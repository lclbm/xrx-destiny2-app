import 'package:flutter/material.dart';
import 'package:xrx/manifest/manifest.service.dart';

typedef void OnFinishCallback();

class DownloadManifestWidget extends StatefulWidget {
  final String title = "Download Database";
  final ManifestService manifest = new ManifestService();
  final String selectedLanguage;
  final OnFinishCallback onFinish;
  DownloadManifestWidget({this.selectedLanguage, this.onFinish});

  @override
  DownloadManifestWidgetState createState() {
    return new DownloadManifestWidgetState();
  }
}

class DownloadManifestWidgetState extends State<DownloadManifestWidget> {
  double _downloadProgress = 0;
  int _loaded = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    if (_downloadProgress == 0) {
      this.download();
    }
  }

  void download() async {
    bool result =
        await this.widget.manifest.download(onProgress: (loaded, total) {
      setState(() {
        _downloadProgress = loaded / total;
        _loaded = (loaded / 1024).floor();
        _total = (total / 1024).floor();
      });
    });

    if (result) {
      this.widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LinearProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              value: (_downloadProgress != null && _downloadProgress < 1)
                  ? _downloadProgress
                  : null,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _downloadProgress < 0.99
                    ? Text(
                        "下载命运2数据库中",
                        key: Key("downloading"),
                      )
                    : Text("解压数据库中", key: Key("unzipping")),
                Text("$_loaded/${_total}KB")
              ],
            )
          ],
        ),
      ),
    );
  }
}
