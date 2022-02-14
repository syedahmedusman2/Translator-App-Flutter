import 'package:bye_bye_localization/bye_bye_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;


class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController _controller = new TextEditingController();
  static final String _startingText =
      "This app can translate many languages without using localization. Simply enter the text you want to translate and press the button.\n We can use this method instead of localization.";
  String _text = _startingText;
  // First language when app starts
  Map<String, String>? originLanguage = {'ENGLISH': "en"};
  Map<String, String>? translateTo;
  bool _translate = true;
  bool textDirection = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: initTranslation(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xff00a2ad),
                title: TranslatedText(
                  'Translator',
                  textDirection:
                      textDirection ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              body: buildBody());
        }
        // UI show when data is still loading
        return Scaffold(
          body: Padding(
                padding: const EdgeInsets.fromLTRB(35,40, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text:
                              'Translating  from ${originLanguage!.keys.first} to ${translateTo == null ? Localizations.localeOf(context).languageCode : translateTo!.keys.first} \n',
                          style: TextStyle(fontSize: 30, color: Colors.black),
                          children: const <TextSpan>[
                            TextSpan(
                                text: 'this might take a while... \n',
                                style: TextStyle(
                                   fontSize: 20)),
                            
                          ],
                        ),
                      ),
                    ),
                    CircularProgressIndicator(
                      strokeWidth: 5,
                    ),
                  ],
                ),
              ),
        );
        
            },
        );
  }
          
    

  Container buildBody() {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        primary: true,
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            onTap: () {
              buildModelSheet().then((value) {
                setState(() {
                  translateTo = value;
                });
              });
            },
            leading: Icon(Icons.translate),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            title: Text(
              "tap to Change Local",
              style: TextStyle(color: Colors.black),
            ),
            subtitle: translateTo != null
                ? Text('${translateTo!.keys.first}')
                : Text('current local is -->'
                    '${LanguageHelper.languages.firstWhere(
                          (k) =>
                              k.values.first == ui.window.locale.languageCode,
                        ).keys.first}'),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                icon: Icon(Icons.edit_rounded),
                hintText: 'Write any text then press translate',
              ),
            ),
          ),
          TextButton(
            child: TranslatedText(
              "Translate the text",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(5), backgroundColor: Color(0xff00a2ad)),
            onPressed: () {
              setState(() {
                _translate = true;
                _text = _controller.text.isNotEmpty
                    ? _controller.text
                    : _startingText;
              });
            },
          ),
          TextButton(
            child: TranslatedText(
              "Change Text direction",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(5), backgroundColor: Color(0xff00a2ad)),
            onPressed: () {
              setState(() {
                textDirection = !textDirection;
              });
            },
          ),
          TextButton(
            child: Text(
              _translate ? "Show Original language" : "Show translation",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(5), backgroundColor: Color(0xff00a2ad)),
            onPressed: () {
              setState(() {
                _translate = !_translate;
              });
            },
          ),
          TextButton(
            child: TranslatedText(
              'Reset text',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(5), backgroundColor: Color(0xff00a2ad)),
            onPressed: () {
              setState(() {
                _text = _startingText;
              });
            },
          ),
          _translate
              ? TranslatedText(_text,
                  textDirection:
                      textDirection ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                  ))
              : Text(
                  _text,
                  textDirection:
                      textDirection ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
        ],
      ),
    );
  }

  Future<bool> initTranslation() async {
    Locale myLocale = Localizations.localeOf(context);
    print('myLocale.languageCode ${ui.window.locale.languageCode}');
    return await TranslationManager().init(
        translateToLanguage: translateTo == null
            ? ui.window.locale.languageCode
            : translateTo!.values.first,
        originLanguage: originLanguage!.values.first);
  }

// Model sheet to show all languages
  Future<Map<String, String>?> buildModelSheet() async {
    return await showModalBottomSheet<Map<String, String>>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      // enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 400,
          child: Center(
            child: ListView.builder(
              itemCount: LanguageHelper.languages.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListTile(
                      // This will set the language to the selected language
                      onTap: () {
                        
                        Navigator.pop(context, LanguageHelper.languages[index]);
                      },
                      title: Text(
                        '${LanguageHelper.languages[index].keys.first}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
