import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

const int httpRequestTimeoutPeriod = 10; //Set Http Request Timeout (Second)
const String sUrlAuthority = 'www.reddit.com';
const String sUrlPath = '/r/FlutterDev.json';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  dynamic _jsonResponse;
  String sTitle = '', sSubTitle = '', sThumbnail = '';
  double iThumbnailHeight = 0,  iThumbnailWidth = 0;

  void _readJsonFromReddit() async {
    var url = Uri.https(sUrlAuthority, sUrlPath);
    dynamic jsonResponse;
    _counter = 0;

    setState(() {
    });

    var response = await http.get(url).timeout(
      const Duration(seconds: httpRequestTimeoutPeriod),
      onTimeout: () {
        return http.Response(
            'Request Timeout ($httpRequestTimeoutPeriod seconds)', 408); // Request Timeout response status code
      },
    );
    if (response.statusCode == 200) {
      jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      _counter = jsonResponse['data']['dist'];
      _jsonResponse = jsonResponse;
      debugPrint(
          'Number of post read from /r/FlutterDev: ${_counter.toString()}.');
    } else {
      debugPrint('Request failed with status: ${response.statusCode} - ${response.body}.');
      alertMessage(response.body, response.statusCode.toString());
    }

    setState(() {});
  }

  Future<void> alertMessage( String parTitle, String parDesc ) async {
    await Alert(context: context,
        title: parTitle,
        desc: parDesc,
        buttons: [
          DialogButton(onPressed: () => Navigator.pop(context), width: 100,child: const Text(
            'OK', style: TextStyle(color: Colors.white, fontSize: 10),),
          )
        ]
    ).show();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Scrollbar(
          child: ListView.builder(
              itemCount: _counter,
              itemBuilder: (context, i) {
                sTitle = _jsonResponse['data']['children'][i]['data']['title'];
                sSubTitle = _jsonResponse['data']['children'][i]['data']['selftext'];
                sThumbnail = _jsonResponse['data']['children'][i]['data']['thumbnail']??'';
                sThumbnail = sThumbnail.startsWith('http')?sThumbnail:'';
                iThumbnailHeight = (_jsonResponse['data']['children'][i]['data']['thumbnail_height']??0).toDouble();
                iThumbnailWidth = (_jsonResponse['data']['children'][i]['data']['thumbnail_width']??0).toDouble();

                return Column(
                  children: [
                    ListTile(
                        title: Text(sTitle),
                        subtitle: Text(sSubTitle),
                      leading: sThumbnail!=''?Image.network(sThumbnail, height: iThumbnailHeight, width:iThumbnailWidth):null
                    ),
                    const Divider()
                  ],
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _readJsonFromReddit,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }



}
