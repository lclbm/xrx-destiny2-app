import 'package:flutter/material.dart';
import 'package:xrx/storage/storage.service.dart';

typedef void LanguageSelectCallback(String languageCode);

class SelectLanguageWidget extends StatefulWidget {
  final String title = "选择你的命运2游戏内语言";
  final Map<String, String> availableLanguages;
  final LanguageSelectCallback onChange;
  final LanguageSelectCallback onSelect;

  SelectLanguageWidget({this.availableLanguages, this.onChange, this.onSelect});

  @override
  SelectLanguageWidgetState createState() => new SelectLanguageWidgetState();
}

class SelectLanguageWidgetState extends State<SelectLanguageWidget> {
  String selectedLanguage;

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  void getLanguage() async {
    await Future.delayed(Duration(milliseconds: 1));
    selectedLanguage = StorageService.getLanguage();
    if (selectedLanguage == null) {
      selectedLanguage = widget.availableLanguages.keys
          .toList()
          .firstWhere((language) => language.isNotEmpty, orElse: () => null);
    }
    widget.onChange(selectedLanguage);
    setState(() {});
  }

  void okClick() {
    StorageService.setLanguage(selectedLanguage);
    if (widget.onSelect != null) {
      widget.onSelect(selectedLanguage);
    }
  }

  List<Widget> getLanguageButtons(BuildContext context) {
    Map<String, String> languages = widget.availableLanguages;

    List<Widget> buttons = [];
    languages.forEach((language, text) {
      buttons.add(FractionallySizedBox(
          widthFactor: 0.4,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: selectedLanguage == language
                      ? Colors.indigoAccent.shade700
                      : Colors.indigo.shade300,
                  elevation: 0,
                  padding: EdgeInsets.all(8)),
              child: Text(text),
              onPressed: () {
                this.setState(() {
                  selectedLanguage = language;
                  widget.onChange(selectedLanguage);
                });
              })));
    });

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(height: 100),
        Text('请选择你的游戏语言'),
        Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 200),
            child: SingleChildScrollView(
                child: Column(children: this.getLanguageButtons(context)))),
        ElevatedButton(
          onPressed: () {
            this.okClick();
          },
          child: Text("确认"),
        )
      ]),
    );
  }
}
