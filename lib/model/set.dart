class PushupSet {
  int id;
  DateTime timestamp;
  int reps;
  int type;

  PushupSet({this.id, this.timestamp, this.reps, this.type});

  factory PushupSet.fromMap(Map<String, dynamic> json) => new PushupSet(
        id: json["id"],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json["timestamp"]),
        reps: json["reps"],
        type: json["type"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "reps": reps,
        "type": type,
      };
}
