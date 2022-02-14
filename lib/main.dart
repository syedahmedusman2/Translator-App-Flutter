import 'package:bye_bye_localization/bye_bye_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: PdfExtraction()
    );
  }
}

class PdfExtraction extends StatefulWidget {
  @override
  _PdfExtractionState createState() => _PdfExtractionState();
}

class _PdfExtractionState extends State<PdfExtraction> {
   TextEditingController _controller = new TextEditingController();
  static final String _startingText =
      "This app can translate from any language to any language. Simply enter the text you want to translate and press the button.\n We can use this method instead of localization";
  String _text = _startingText;
  // First language when app starts
  Map<String, String>? originLanguage = {'ENGLISH': "en"};
  Map<String, String>? translateTo;
  bool _translate = true;
  bool textDirection = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  TranslatedText(
            'Translator App',
            style: TextStyle(fontSize: 24),
          ),
        ),
        body:
        FutureBuilder(
          // Initialize FlutterFire:
          future: initTranslation(),
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              return buildBody();
            }

            // UI show when data is still loading
            return Padding(
              padding: const EdgeInsets.all(8.0),
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
                              text: 'Please wait for some time\n',
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
            );
          },
        )
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
                padding: EdgeInsets.all(5), backgroundColor: Colors.blueAccent),
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
                padding: EdgeInsets.all(5), backgroundColor: Colors.blueAccent),
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
                padding: EdgeInsets.all(5), backgroundColor: Colors.blueAccent),
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
                padding: EdgeInsets.all(5), backgroundColor: Colors.blueAccent),
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

  Future<bool> initWidget() async {
    return await TranslationManager().init(
      originLanguage: Languages.ENGLISH,
      translateToLanguage: Languages.ARABIC,
    );
  }
// Model sheet to show all languages
  Future<Map<String, String>?> buildModelSheet() async {
    return await showModalBottomSheet<Map<String, String>>(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration:const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft:Radius.circular(11),topRight: Radius.circular(11)),
          ),
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