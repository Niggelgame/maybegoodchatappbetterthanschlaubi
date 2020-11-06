import 'package:chatting_app/views/home.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _usernameController =
      TextEditingController(text: 'Hello Socket!');

  String hostname = "192.168.19.66";
  int port = 8081;

  void _joinChat() {
    if (_usernameController.text.isEmpty) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Please provide username')));
      return;
    }
    if (hostname.isEmpty) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Hostname needs to be provided')));
      return;
    }
    if (hostname.isEmpty) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Hostname needs to be provided')));
      return;
    }
    if (port == null) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Port needs to be provided')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => Home(
                username: _usernameController.text,
                password: "2",
                host: hostname,
                port: port,
              )
          // builder: (_) => ChatView(name: _usernameController.text),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Host: $hostname'),
            RaisedButton(
              onPressed: () async {
                var name = await showTextInputDialog(
                  context: context,
                  textFields: [
                    DialogTextField(
                      hintText: 'hostname',
                      validator: (text) {
                        if (text.isEmpty) {
                          return "Text may not be empty";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                );
                if (name.isNotEmpty && name.length > 0) {
                  setState(() {
                    hostname = name[0];
                  });
                }
              },
              child: Text('Change hostname'),
            ),
            Text('Port: $port'),
            RaisedButton(
              onPressed: () async {
                var stringport = await showTextInputDialog(
                  context: context,
                  textFields: [
                    DialogTextField(
                      hintText: 'Port',
                      validator: (text) {
                        if (text.isEmpty) {
                          return "Port may not be empty";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                );
                if (stringport.isNotEmpty && stringport.length > 0) {
                  int p = int.tryParse(stringport[0]);
                  if(p != null) {
                    setState(() {
                      port = p;
                    });
                  } else {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Only numbers can be inputted')));
                    return;
                  }
                }
              },
              child: Text('Change hostname'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: "Username"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _joinChat,
        tooltip: 'Join',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
