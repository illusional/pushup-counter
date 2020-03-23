import 'package:flutter/material.dart';
import 'package:pushup_counter/data/database.dart';
import 'package:pushup_counter/model/day.dart';

class PreviousDays extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DBProvider.db.getLastNDays(7),
        builder: (BuildContext context, AsyncSnapshot<List<Day>> snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (!snapshot.hasData) return Text("Loading...");
          List<int> sized = snapshot.data.map((d) => d.reps).toSet().toList();
          sized.sort((a, b) => a.compareTo(b));

          var sizeLookup = new Map<int, int>();
          var scale = 8 / sized.length;
          for (var i = 0; i < sized.length; i++) {
            sizeLookup[sized[i]] = ((i + 1) * scale).toInt() * 100;
          }

          return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Day item = snapshot.data[index];
                if (item == null) return Text("Something happened...");

                return Container(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                      color: Colors.amber[sizeLookup[item.reps]],
                      padding: const EdgeInsets.all(10),
                      child: Center(
                          child: Column(children: [
                        Text(
                            "${item.date.day}/${item.date.month}/${item.date.year}"),
                        Text("${item.reps} Reps")
                      ]))),
                ));
              });
        });
  }
}
