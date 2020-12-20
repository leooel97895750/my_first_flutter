import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('demo'),
      ),
      body: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, idx){
            return Card(child: Container(
              height: 150,
              color: Colors.blue,
              child: Text('$idx'),
            ),);
          }
      ),
    );
  }
}
