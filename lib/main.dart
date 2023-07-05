import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/shared_values.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;
  List<Widget> pages = const [HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Johar family'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 239, 109, 27),
                  Color(0xFF00CCFF),
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: pages[currentPage],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Floating action button');
          //currentPage++;
        },
        child: const Icon(Icons.ac_unit),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.calendar_today, color: Colors.blue), label: 'Date'),
        ],
        onDestinationSelected: (int index) {
          if(index == 2){
            _datePicker(context);
          }else{
            setState(() {
              currentPage = index;
            });
          }
        },
        selectedIndex: currentPage,
      ),
    );
  }

  void _datePicker(BuildContext context) async{
    DateTime selectedDate;
    if(AppValues.dateForVideos.isNotEmpty){
      selectedDate = DateTime.parse(AppValues.dateForVideos);
    }else{
      selectedDate = DateTime.now();
    }
    DateTime? pickedDate = await showDatePicker(
        context: context, //context of current state
        initialDate: selectedDate,
        firstDate: DateTime(1990), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );

    if(pickedDate != null ){
      debugPrint(pickedDate.toString());  //pickedDate output format => 2021-03-10 00:00:00.000
      AppValues.dateForVideos = pickedDate.toString();
      //String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      //print(formattedDate); //formatted date output using intl package =>  2021-03-16
    }else{
      debugPrint("Date is not selected");
    }
  }
}
