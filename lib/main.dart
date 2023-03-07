import 'package:flutter/material.dart';
import 'todo_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef void CallBack(String itemId, TodoItem todoItem);

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final db = FirebaseFirestore.instance;


  void addTodo(String? itemId, TodoItem? item) async {
    await db.collection('todos').add(item!.toFirestore());
  }

  void updateTodo(String? itemId, TodoItem? item) async {


    var itemQuery = db.collection('todos');
    itemQuery.get().then((value) {
      for (DocumentSnapshot val in value.docs) {
        if (val.id == itemId) {
          val.reference.update(item!.toFirestore());
        }
      }
    });
  }

  void deleteTodo(String? itemId, TodoItem? todoItem) async {
    var itemQuery = db.collection('todos');
    itemQuery.get().then((value) {
      for (DocumentSnapshot val in value.docs) {
        if (val.id == itemId) {
          val.reference.delete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('todos').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'Nothing Here',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w700),
                ),
              );
            }
            return ListView(
              children:
                  snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
                String itemId = documentSnapshot.id;
                TodoItem todoItem = TodoItem.fromFirestore(
                    documentSnapshot as DocumentSnapshot<Map<String, dynamic>>,
                    SnapshotOptions());
                return ListTile(
                  title: Text(
                    todoItem.content,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    todoItem.createdAt.toDate().toLocal().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  trailing: Wrap(spacing: 10, children: [
                    IconButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ShowAlertDialog(
                                  initialText: todoItem.content,
                                  callBack: updateTodo);
                            }),
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            deleteTodo(itemId, todoItem);
                          });
                        },
                        icon: Icon(Icons.delete)),
                  ]),
                );
              }).toList(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return ShowAlertDialog(callBack: addTodo);
              }),
          tooltip: 'Add New Todo Task',
          child: const Icon(Icons.add),
        ));
  }
}

class ShowAlertDialog extends StatefulWidget {
  final String initialText;
  final CallBack callBack;

  const ShowAlertDialog(
      {Key? key, this.initialText = '', required this.callBack})
      : super(key: key);

  @override
  State<ShowAlertDialog> createState() => _ShowAlertDialogState();
}

class _ShowAlertDialogState extends State<ShowAlertDialog> {
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    contentController.text = widget.initialText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          TextFormField(
            controller: contentController,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.callBack(
                '',
                TodoItem(
                    content: contentController.text,
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now(),
                    done: false));
            Navigator.of(context).pop();
          },
          child: Text(
            widget.initialText.length == 0 ? 'Add Task' : 'Update Task',
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'))
      ],
    );
  }
}
