import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// 主程式進入點
void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHome(),
  ),
);

// 下方點擊列，透過點擊改變body內容
class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}
class _MyHomeState extends State<MyHome> {
  //在MyContent中加入GlobalKey 使用MyCoontent中的函式 [MyContent需要加上MyContent({Key key}):super(key:key);]
  GlobalKey<_MyContentState> indexGlobalKey = new GlobalKey<_MyContentState>();
  int index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyContent(key: indexGlobalKey),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          // 點擊改變index
          onTap: (int idx){
            print(idx);
            setState(() {
              // 若在index == 1的情況下點擊，將跳轉至文章列表
              if(index == 1 && idx == 1){
                indexGlobalKey.currentState.updateArticlePage(0);
              }
              index = idx;
              // 更新index
              indexGlobalKey.currentState.updateIndex(index);
              // 將跳轉至學校
              indexGlobalKey.currentState.updateSchoolPage(1);
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

// 以下列表正常來說要從資料庫取，這裡快速demo
var school = ['國立台灣大學', '國立交通大學', '國立清華大學', '國立成功大學', '國立政治大學'];
var department = ['資訊工程學系', '機械工程學系', '電機工程學系', '光電科學與工程學系', '物理治療學系', '中國文學系', '台灣文學系', '地球科學學系', '化學工程學系', '工業設計學系', '護理學系', '醫學系', '工業與資訊管理學系'];
var isStamp = [1,0,0,0,0,0,0,0,0,0,0,0,0];
// MyHome的body部分，隨index調整
class MyContent extends StatefulWidget {
  MyContent({Key key}):super(key:key);
  @override
  _MyContentState createState() => _MyContentState();
}
class _MyContentState extends State<MyContent>{
  var local_index = 1;
  ScrollController myscroll = new ScrollController();
  // 網頁資料
  var api_list = 'https://www.tuuuna.com/api/getapplist?cid=4&page=';
  var api_article = 'https://www.tuuuna.com/api/getapparticle?aid=';
  var api_file = 'https://www.tuuuna.com/api/getapparticlefile?aid=';
  var page = 0; // 當前列表頁數
  var datas = []; // 列表全部資料
  var article = []; // 文章內容
  var files = []; // 文章相關檔案
  var myaid = 0; // 目前文章id
  // local頁面的切換
  var article_page = 0;
  var school_page = 1;

  // 初始設定
  @override
  void initState(){
    super.initState();
    getList();
    myscroll.addListener(() {
      //print(myscroll.position.pixels); //滾動位置
      if(myscroll.position.pixels == myscroll.position.maxScrollExtent) {
        print('滑到底了');
        setState(() {
          page = page + 1;
          getList();
        });
      }
    });
  }

  // 更新顯示頁面
  void updateIndex(remote_index) {
    setState(() {
      local_index = remote_index;
    });
  }
  // 切換文章內容至列表
  void updateArticlePage(remote_page){
    setState(() {
      article_page = remote_page;
    });
  }
  // 切換科系至學校
  void updateSchoolPage(remote_page){
    setState(() {
      school_page = remote_page;
    });
  }

  @override
  Widget build(BuildContext context){
    switch(local_index) {

      // 首頁 選校選科系來訂閱文章
      case 0: {

        if(school_page == 1){
          return Container(
            color: Colors.black87,
            child: ListView(
              children: List.generate(school.length, (idx){
                var data = school[idx];
                print(idx);
                return Card(
                  clipBehavior : Clip.antiAliasWithSaveLayer,
                  child: Container(
                    color: Colors.grey,
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      leading: Image.asset('assets/school'+idx.toString()+'.png'),
                      title: Text(data, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white),),
                      trailing: Icon(Icons.arrow_forward),
                      // 點擊進入科系
                      onTap: () {
                        print(data);
                        setState(() {
                          school_page = 0;
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
          );
        }
        else{
          return Container(
            color: Colors.black87,
            child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2 / 1,
            children: List.generate(department.length, (idx){
              var stamp = (isStamp[idx] == 1) ? "assets/stamp.png" : "assets/white.png";
              var data = department[idx];
              return Card(
                clipBehavior : Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: DecorationImage(
                        alignment:Alignment.bottomRight,
                        colorFilter: ColorFilter.mode(Colors.grey.withOpacity(0.2), BlendMode.srcOver),
                        image: AssetImage(stamp),
                      ),
                    ),
                    alignment:Alignment.center,

                    child: Text(data, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 20),),
                  ),
                  onTap: (){
                    if(isStamp[idx] == 0){
                      Alert(
                        context: context,
                        title: "成功訂閱了喔~",
                        desc: "幹得漂亮!",
                        buttons: [
                          DialogButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        ],
                      ).show();
                      setState(() {
                        isStamp[idx] = 1;
                      });
                    }
                    else{
                      Alert(
                        context: context,
                        title: "要取消訂閱嗎?",
                        desc: "QwQ",
                        image: Image.asset("assets/cat.jpeg"),
                        buttons: [
                          DialogButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        ],
                      ).show();
                      setState(() {
                        isStamp[idx] = 0;
                      });
                    }
                  },
                ),
              );
            }),
          ),
          );
        }

      }
      break;

      // 文章列表 or 文章內容
      case 1: {
        // 列表
        if(article_page == 0){
          return Container(
              color: Colors.black87,
              child: ListView(
                controller: myscroll,
                children: List.generate(datas.length, (idx){
                  var data = datas[idx];
                  Color title_status = Colors.red;
                  if(data['Status'] == "一般"){title_status = Colors.green;}
                  else if(data['Status'] == "重要"){title_status = Colors.deepOrange;}
                  else if(data['Status'] == "大學部"){title_status = Colors.blueAccent;}
                  else if(data['Status'] == "研究所"){title_status = Colors.yellow;}
                  else if(data['Status'] == "博士"){title_status = Colors.purple;}
                  else{title_status = Colors.black;}
                  return Card(
                    child: Container(
                      height: 120,
                      padding: EdgeInsets.only(bottom: 40),
                      //color: Colors.green,
                      child: ListTile(
                        title: Text(data['Title'], overflow: TextOverflow.ellipsis, style: TextStyle(color: title_status, fontWeight: FontWeight.bold),),
                        subtitle: Html(data: data['Content']),
                        // 點擊進入文章
                        onTap: () {
                          print(data['AID']);
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

        // 詳細文章內容
        else{
          if(article == []){
            return Container(color: Colors.black45,);
          }
          else{
            Color article_status = Colors.red;
            if(article[0]['Status'] == "一般"){article_status = Colors.green;}
            else if(article[0]['Status'] == "重要"){article_status = Colors.deepOrange;}
            else if(article[0]['Status'] == "大學部"){article_status = Colors.blueAccent;}
            else if(article[0]['Status'] == "研究所"){article_status = Colors.yellow;}
            else if(article[0]['Status'] == "博士"){article_status = Colors.purple;}
            else{article_status = Colors.black;}
            return Container(
                color: Colors.black87,
                child: ListView(children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          article[0]['Title'],
                          style: TextStyle(fontSize: 20, color: article_status),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(top: 15),
                              alignment:Alignment.center,
                              constraints: BoxConstraints(maxHeight: 28, minHeight: 28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                border: Border.all(width: 2, color: Colors.teal),
                              ),
                              child: Text(article[0]['Type'], style: TextStyle(fontSize: 14),),
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(top: 15),
                              alignment:Alignment.center,
                              constraints: BoxConstraints(maxHeight: 28, minHeight: 28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                border: Border.all(width: 2, color: Colors.green),
                              ),
                              child: Text(article[0]['Author'], style: TextStyle(fontSize: 14),),
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(top: 15),
                              alignment:Alignment.center,
                              constraints: BoxConstraints(maxHeight: 28, minHeight: 28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                border: Border.all(width: 2, color: Colors.green),
                              ),
                              child: Text(article[0]['Since'].replaceAll('-', '/').substring(0, article[0]['Since'].lastIndexOf(':')), style: TextStyle(fontSize: 14),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(
                          data: article[0]['Content'],
                        ),
                        Divider(),
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: Text('相關連結: ' + article[0]['URL']),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: ListView(
                      shrinkWrap: true, //解決無限高度問題
                      physics:NeverScrollableScrollPhysics(),//禁用滑動事件
                      children: List.generate(files.length, (idx){
                        var data = files[idx];
                        return Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            border: Border.all(width: 2, color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: Container(
                                  child: Text(data['FileName'], style: TextStyle(color: Colors.white70),),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: Column(
                                    children: [
                                      InkWell(
                                        child: Text('下載檔案', style: TextStyle(fontSize: 16, color: Colors.blue),), //data['FileURL']
                                        onTap: (){
                                          _launchURL(data['FileURL']);
                                        },
                                      ),
                                      Text(data['UploadDate'], style: TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),


                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],)
            );
          }
        }

      }
      break;

      // 設定
      case 2: {
        return Container(color: Colors.yellow);
      }
      break;

      // 出錯啦!!!
      default: {
        return Container(color: Colors.red);
      }
      break;
    }
  }

  // API取資料
  void getList() async{
    var response = await http.get(api_list + page.toString());
    setState((){
      datas.addAll((jsonDecode(utf8.decode(response.bodyBytes))));
    });
  }
  void getArticle() async{
    var response = await http.get(api_article + myaid.toString());
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    getFile(result);
  }
  void getFile(result) async{
    var response = await http.get(api_file + myaid.toString());
    setState((){
      article = result;
      files = jsonDecode(utf8.decode(response.bodyBytes));
      article_page = 1;
    });
  }

  _launchURL(String url) async {
    url = Uri.encodeFull(url); // url to url encode.
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}