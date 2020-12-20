import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
  home: MyApp(),
));

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;
  String page2Data;
  List<Widget> pages = [
    MyWeather(),
    Container(color: Colors.blue),
    Container(color: Colors.green),
    Container(color: Colors.orange)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      // floatingActionButton: FloatingActionButton(onPressed: (){
      //   //Navigator.pushNamed(context, '/page2');
      //   Navigator.of(context).push(MaterialPageRoute(builder: (context){
      //       return Page2(textData: 'abc');
      //   })).then((value){print(value);});
      // }),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: (int idx){
            print(idx);
            setState(() {
              index = idx;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('A')),
            BottomNavigationBarItem(icon: Icon(Icons.add_a_photo_outlined), title: Text('B')),
            BottomNavigationBarItem(icon: Icon(Icons.access_alarm), title: Text('C')),
            BottomNavigationBarItem(icon: Icon(Icons.accessibility), title: Text('D')),
          ]
      ),
    );
  }
}

class MyWeather extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return ListView(
      children: List.generate(10, (idx){
        print(idx);
        return Card(child: Container(
          height: 150,
          color: Colors.green,
          child: Text('$idx'),
        ),);
      }),
    );
  }
}