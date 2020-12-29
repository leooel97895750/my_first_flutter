import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';

class MyState extends BlocBase{
  //變數
  var index = 0;

  StreamController _myController = new StreamController();
  // 讓外部能取到
  get myController => _myController.stream;

  //函式
  void changeState(){
    index++;
    _myController.add(index);
  }

  //關閉
  @override
  void dispose(){
    _myController.close();
    super.dispose();
  }

}