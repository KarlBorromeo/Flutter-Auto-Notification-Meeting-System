import 'package:flutter/material.dart';
import 'package:meet/calendar.dart';
import 'package:meet/providers/calendar_provider.dart';
import 'package:provider/provider.dart';
import 'package:cron/cron.dart';
import 'dash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference _cron = FirebaseFirestore.instance.collection('cron');

void main() async {
  // final cron = Cron();
  // var i = 'karl';
  // cron.schedule(Schedule.parse('*/5 * * * * *'),
  //     () async => {
  //       // print(i++)
  //       _cron.add({
  //         'name': i
  //       })
  //       });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarState()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: const calendar(),
      // home: example(),
    );
  }
}
