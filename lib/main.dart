import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // jsonDecodeを使うために必要
import 'package:http/http.dart'; // http package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'getAPI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'API通信をして住所検索'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final zipCodeController = TextEditingController(); // 入力された郵便番号を保持する変数
  final addressController = TextEditingController(); // 入力された住所を保持する変数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('郵便番号'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: '郵便番号を入力してください',
                    ),
                    maxLength: 7,
                    // 最大文字数
                    onChanged: (value) async {
                      // 入力された郵便番号が7文字でなければ何もしない
                      if (value.length != 7) {
                        return;
                      }
                    },
                    controller: zipCodeController,
                    // 入力された郵便番号を保持
                    keyboardType: TextInputType.number,
                    // 数字のみ入力できるように設定
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                OutlinedButton(
                  child: const Text('検索'),
                  onPressed: () async {
                    // 入力された郵便番号を取得
                    final address =
                        await zipCodeToAddress(zipCodeController.text);
                    // 返ってきた値がnullなら終了
                    if (address == null) {
                      return;
                    }
                    // 住所が帰ってきたらaddressControllerを上書き
                    addressController.text = address;
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: '住所',
              ),
              controller: addressController, // 入力された住所を保持しているためそれを表示
            ),
          ],
        ),
      ),
    );
  }
}

// 郵便番号を住所に変換する関数
Future<String?> zipCodeToAddress(String zipCode) async {
  if (zipCode.length != 7) {
    return null;
  }
  final url = 'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode';
  final response = await get(
    Uri.parse(url),
  );

  // print(response.statusCode);
  // 正常なステータスコードが返って来ているか
  if (response.statusCode != 200) {
    return null;
  }
  // 住所はあるか
  final result = jsonDecode(response.body);
  if (result['results'] == null) {
    return null;
  }
  final addressMap = (result['results'] as List).first; // List型に変換
  final address =
      '${addressMap['address1']} ${addressMap['address2']} ${addressMap['address3']}';
  return address;
}