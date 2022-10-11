import 'package:flutter/material.dart';
import 'package:flutter_application_1/alexa_voice_says.dart';
import 'package:flutter_application_1/harsha_task.dart';
import 'package:flutter_application_1/learn_flutter_page.dart';
import 'package:flutter_application_1/manage_photos.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Harsha game'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  debugPrint("Actions");
                },
                icon: const Icon(Icons.info))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const LearnFlutterPage();
                    },
                  ),
                );
              },
              child: const Text('Learn Flutter'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const HarshaTask();
                    },
                  ),
                );
              },
              child: const Text('Create harsha task'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const AlexaVoiceSays();
                    },
                  ),
                );
              },
              child: const Text('Alexa voices'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                      return const ManagePhotos();
                    },
                  ),
                );
              },
              child: const Text('Manage photos'),
            )
          ])),
        ));
  }
}
