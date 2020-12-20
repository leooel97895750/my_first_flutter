import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
  home: new HomePage2(),
));

class HomePage2 extends StatefulWidget{
  @override
  HomePage2State createState() => HomePage2State();
}

class HomePage2State extends State<HomePage2>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.forward),
          onPressed: (){
            setState(() {

            });
          }
      ),
      appBar: new AppBar(
        title: Text('!!!'),
      ),
      body: Row(
        children: <Widget>[
          Container(
            color: getColor(),
            width: 100.0,
            height: 100.0,
          ),
          Container(
            color: getColor(),
            width: 100.0,
            height: 100.0,
          ),
        ],
      ),
    );
  }
  Color getColor(){
    return Color.fromARGB(255, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255));
  }
}