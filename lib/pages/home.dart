import 'package:flutter/material.dart';
import 'pages.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _currentIndex = 0;
  final List _listPages = <Widget>[];
  late Widget _currentPage;
  PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    _listPages
      ..add(const InfoQueryPage())
      ..add(const DataSqlitePage())
      ..add(const UserPage());
    _currentPage = const InfoQueryPage();
  }

  void _changePage(int selectedIndex) {
    setState(() {
      _currentIndex = selectedIndex;
      _currentPage = _listPages[selectedIndex];
      _pageController.jumpToPage(selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
          child: PageView.builder(
        itemBuilder: (context, index) => _listPages[index],
        onPageChanged: _changePage,
        itemCount: _listPages.length,
        controller: _pageController,
      )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cake), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.data_usage), label: '数据库'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: '我'),
        ],
        onTap: (selectedIndex) => _changePage(selectedIndex),
      ),
    );
  }
}
