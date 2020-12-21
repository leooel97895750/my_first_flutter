import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lazy_loading_list/lazy_loading_list.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();


void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MyHome(),
));

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int index = 0;
  List<Widget> pages = [
    Myindex(),
    Mysubscription(),
    Mysetting(),
  ];

  @override
  void initState(){
    super.initState();
  }

  getInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"

    // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    // print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
  }

  @override
  Widget build(BuildContext context) {
    //getInfo();
    return Scaffold(
      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: (int idx){
            //print(idx);
            setState(() {
              index = idx;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首頁'),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: '訂閱'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
          ]
      ),
    );
  }
}

// 訂閱內容顯示頁
class Mysubscription extends StatefulWidget {
  @override
  _MysubscriptionState createState() => _MysubscriptionState();
}
class _MysubscriptionState extends State<Mysubscription>{
  var page = 0;
  var api = 'https://www.tuuuna.com/api/getapplist?cid=4&page=';
  var datas = [];
  ScrollController myscroll = new ScrollController();

  @override
  void initState(){
    super.initState();
    getData();
    myscroll.addListener(() {
      //print(myscroll.position.pixels); //滾動位置
      if(myscroll.position.pixels == myscroll.position.maxScrollExtent) {
        print('滑到底了');
        setState(() {
          page = page + 1;
          getData();
        });
      }
    });
  }

  getData() async{
    var response =  await http.get(api + page.toString());
    setState((){
      datas.addAll((jsonDecode(utf8.decode(response.bodyBytes))));
    });
  }

  @override
  Widget build(BuildContext context){
    return Container(
      color: Colors.green,
      child: ListView(
        controller: myscroll,
        children: List.generate(datas.length, (idx){

          var data = datas[idx];
          return Card(child: Container(
            height: 120,
            padding: EdgeInsets.only(bottom: 40),
            //color: Colors.green,
            child: ListTile(title: Text(data['Title'], overflow: TextOverflow.ellipsis), subtitle: Html(data: data['Content'])),
          ),);
        }),
      )
    );
    // return FutureBuilder(future: jsonlist, builder: (context, snap){
    //   if(!snap.hasData){
    //     return Container(color: Colors.green);
    //   }
    //   var datas = jsonDecode(utf8.decode(snap.data.bodyBytes));
    //   return Container(
    //     color: Colors.green,
    //     child: ListView(
    //       controller: myscroll,
    //       children: List.generate(10, (idx){
    //
    //         var data = datas[idx];
    //         return Card(child: Container(
    //           height: 120,
    //           padding: EdgeInsets.only(bottom: 40),
    //           //color: Colors.green,
    //           child: ListTile(title: Text(data['Title'], overflow: TextOverflow.ellipsis), subtitle: Html(data: data['Content'])),
    //         ),);
    //       }),
    //     ),
    //   );
    // });
  }
}

// 首頁，編輯訂閱內容，產品介紹
class Myindex extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(color: Colors.orange);
  }
}

// 設定，不知道可以設定什麼
class Mysetting extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(color: Colors.blue);
  }
}