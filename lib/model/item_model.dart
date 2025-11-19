class Item {
  final int? id;
  final String title;
  final String description;
  final String status;
  final String time;

  Item({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'time': time,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      time: map['time'],
    );
  }
}
