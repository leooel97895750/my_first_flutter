import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lazy_loading_list/lazy_loading_list.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
var isArticle = 0;

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
              isArticle = 0;
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
  //var isArticle = 0;
  var myaid = 0;
  var article = [];
  var files = [];
  var page = 0;
  var api_list = 'https://www.tuuuna.com/api/getapplist?cid=4&page=';
  var api_article = 'https://www.tuuuna.com/api/getapparticle?aid=';
  var api_file = 'https://www.tuuuna.com/api/getapparticlefile?aid=';
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

  // API取資料
  getData() async{
    var response = await http.get(api_list + page.toString());
    setState((){
      datas.addAll((jsonDecode(utf8.decode(response.bodyBytes))));
    });
  }
  getArticle() async{
    var response = await http.get(api_article + myaid.toString());
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    getFile(result);
  }
  getFile(result) async{
    var response = await http.get(api_file + myaid.toString());
    setState((){
      article = result;
      files = jsonDecode(utf8.decode(response.bodyBytes));
      //print(files);
    });
  }

  @override
  Widget build(BuildContext context){
    // 列表頁面
    if(isArticle == 0){
      return Container(
          color: Colors.green,
          child: ListView(
            controller: myscroll,
            children: List.generate(datas.length, (idx){

              var data = datas[idx];
              return Card(
                child: Container(
                  height: 120,
                  padding: EdgeInsets.only(bottom: 40),
                  //color: Colors.green,
                  child: ListTile(
                    title: Text(data['Title'], overflow: TextOverflow.ellipsis),
                    subtitle: Html(data: data['Content']),
                    // 點擊進入文章
                    onTap: () {
                      print(data['AID']);
                      isArticle = 1;
                      myaid = data['AID'];
                      getArticle(); //取得文章和檔案
                    },
                  ),
                ),
              );
            }),
          )
      );
    }
    // 文章頁面
    else{
      if(article == []){
        return Container(color: Colors.green,);
      }
      else{
        return Container(
          color: Colors.green,
          child: ListView(children: [
            Text(article[0]['Title']),
            Text('相關連結: ' + article[0]['URL']),
            Html(data: article[0]['Content']),
            Text(article[0]['Type']),
            Text(article[0]['Status']),
            Text(article[0]['Author']),
            Text(article[0]['Since']),
            ListView(
              shrinkWrap: true, //解決無限高度問題
              physics:NeverScrollableScrollPhysics(),//禁用滑動事件
              children: List.generate(files.length, (idx){
              var data = files[idx];
              return ListView(
                shrinkWrap: true, //解決無限高度問題
                physics:NeverScrollableScrollPhysics(),//禁用滑動事件
                children: [
                Text(data['FileName']),
                Text(data['UploadDate']),
                Text(data['FileURL']),
              ]);
            }),
            ),
          ],)
        );
      }
    }
  }
}

// 文章
class Myarticle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(color: Colors.green);
    //收參數並顯示
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