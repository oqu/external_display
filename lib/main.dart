import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

const MethodSetCounter = "setCounter";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'External display adventure'),
      routes: {
        "/external" : (context) =>  ExternalDisplay(),
        },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  static const platform = const MethodChannel('io.github.oqu/externalA');

  void _incrementCounter() {
    platform.invokeMethod(MethodSetCounter,[_counter + 1]);
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}



class ExternalDisplay extends StatefulWidget {
  @override
  _ExternalDisplayState createState() => _ExternalDisplayState();
}

int getFirstInteger(dynamic args) {
  if (args is! List<dynamic>) {
    return null;
  }
  var ld = args as List<dynamic>;
  if (ld.length > 0) {
    if (ld[0] is int) {
      return (ld[0] as int);
    }
  }
  return null;
}


class _ExternalDisplayState extends State<ExternalDisplay> {
  int counter = 0;
  static const platform = const MethodChannel('io.github.oqu/externalB');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    platform.setMethodCallHandler((message) async {
      if (message.method == MethodSetCounter) {
        var c = getFirstInteger(message.arguments);
        if (c != null) {
          setState(() {
          counter = c;
        });
        }
      }
      return "ok";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Center(child: Text("External counter: $counter"),),),);
  }
}