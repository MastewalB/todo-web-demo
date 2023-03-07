import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String content;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool done;

  const TodoItem({
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.done,
  });

  factory TodoItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? option,
  ) {
    final data = snapshot.data();
    return TodoItem(
        content: data?['content'],
        createdAt: data?['createdAt'],
        updatedAt: data?['updatedAt'],
        done: data?['done']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'done': done,
    };
  }
}
