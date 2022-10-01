import 'package:flutter/material.dart';
import 'package:flutter_application_1/harsha_task.dart';
import 'package:flutter_application_1/learn_flutter_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext buildContext) {
                  return const LearnFlutterPage();
                },
              ),
            );
          },
          child: const Text('Learn Flutter')),
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext buildContext) {
                  return const HarshaTask();
                },
              ),
            );
          },
          child: const Text('Create harsha task'))
    ]));
  }
}
