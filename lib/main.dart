import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

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
  var article_page = 0;

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
      article_page = 0;
    });
  }

  @override
  Widget build(BuildContext context){
    switch(local_index) {

      // 首頁
      case 0: {
        return Container(color: Colors.blue);
      }
      break;

      // 文章列表 or 文章內容
      case 1: {
        // 列表
        if(article_page == 0){
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

}