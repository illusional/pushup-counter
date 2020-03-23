import 'package:flutter/material.dart';
import 'package:pushup_counter/data/database.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({Key key}) : super(key: key);

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<CounterWidget> {
  int _reps = -1;

  void _addReps({int reps}) async {
    int newValue = await DBProvider.db.addPushupSet(reps, null);
    setState(() {
      _reps = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: DBProvider.db.getTodaysTally(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (!snapshot.hasData) return Text("Loading...");

          if (_reps < 0) {
            _reps = snapshot.data;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$_reps', style: TextStyle(fontSize: 64)),
                Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 40),
                    child: Text(
                      'You have completed this many push-ups',
                    )),
                Padding(
                  child: RaisedButton(
                    child: Text("I did 5 pushups"),
                    onPressed: () => _addReps(reps: 5),
                  ),
                  padding: EdgeInsets.only(top: 10),
                ),
                Padding(
                  child: RaisedButton(
                    child: Text("I did 10 pushups!"),
                    onPressed: () => _addReps(reps: 10),
                  ),
                  padding: EdgeInsets.only(top: 10),
                )
              ],
            ),
          );
        });
  }
}
