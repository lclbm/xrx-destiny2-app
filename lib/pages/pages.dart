import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/bungie_api/api.dart';

class InfoQueryPage extends StatefulWidget {
  const InfoQueryPage({Key? key}) : super(key: key);

  @override
  _InfoQueryPageState createState() => _InfoQueryPageState();
}

class _InfoQueryPageState extends State<InfoQueryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('命运2小日向助手'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text('Drawer Header'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.adjust),
              title: const Text('Item 1'),
              onTap: () async {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: QueryWidget(),
    );
  }
}

class QueryWidget extends StatefulWidget {
  const QueryWidget({Key? key}) : super(key: key);

  @override
  _QueryWidgetState createState() => _QueryWidgetState();
}

class _QueryWidgetState extends State<QueryWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late String name;
  var items = <DestinyCharacterComponent>[];
  late var profileData;

  Widget buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      autofocus: false,
      onChanged: (value) {
        name = value;
      },
      onSubmitted: (value) async {
        var a = await BungieApiService.getProfile(
            [DestinyComponentType.Characters, DestinyComponentType.Profiles],
            '4611686018497181967',
            BungieMembershipType.TigerSteam);
        var characterList = a!.characters!.data!.values;
        items.addAll(characterList);
        setState(() {});
      },
      decoration: InputDecoration(
          icon: const Icon(Icons.text_fields),
          fillColor: Colors.blue.shade100,
          filled: true,
          labelText: '请输入你要查询的BungieId'),
    );
  }

  var textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget createCard(BuildContext context, int index) {
    var item = items[index];
    String bigEmblemUrl =
        BungieApiService.parseUrl(item.emblemBackgroundPath as String);
    String smallEmblemUrl =
        BungieApiService.parseUrl(item.emblemPath as String);
    String className = item.classType.toString();
    String dateLastPlayed = item.dateLastPlayed as String;
    print(3);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      color: Colors.white60,
      //z轴的高度，设置card的阴影
      elevation: 20.0,
      //设置shape，这里设置成了R角
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      //对Widget截取的行为，比如这里 Clip.antiAlias 指抗锯齿
      clipBehavior: Clip.antiAlias,
      semanticContainer: false,
      child: Column(
        children: <Widget>[
          Container(
            child: Image.network(
              bigEmblemUrl,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.all(10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(smallEmblemUrl),
            ),
            title: Text(className),
            subtitle: Text(
              dateLastPlayed,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: buildTextField(textController),
                width: 270,
              ),
              ElevatedButton(
                child: Text('查询'),
                onPressed: () async {
                  var a = await BungieApiService.getProfile([
                    DestinyComponentType.Characters,
                    DestinyComponentType.Profiles
                  ], '4611686018497181967', BungieMembershipType.TigerSteam);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: '关闭',
                        onPressed: () {
                          // Code to execute.
                        },
                      ),
                      content: const Text('查询成功啦！'),
                      duration: const Duration(milliseconds: 3000),
                      width: 280.0, // Width of the SnackBar.
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, // Inner padding for SnackBar content.
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: createCard,
            itemCount: items.length,
          ),
        )
      ],
    );
  }
}

class DataSqlitePage extends StatefulWidget {
  const DataSqlitePage({Key? key}) : super(key: key);

  @override
  _DataSqlitePageState createState() => _DataSqlitePageState();
}

class _DataSqlitePageState extends State<DataSqlitePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Icon(Icons.money, size: 120, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: const [
          SizedBox(
            height: 150,
            child: Center(
              child: Text('内容'),
            ),
          ),
          ListTile(
            title: Text('设置'),
            subtitle: Text('修改有关设置'),
            leading: Icon(Icons.settings),
          ),
          ListTile(
            title: Text('设置'),
            subtitle: Text('修改有关设置'),
            leading: Icon(Icons.settings),
          )
        ],
      ));
}
