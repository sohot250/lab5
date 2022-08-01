import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'InfiniteScrollPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> items = List.generate(3, (index) => 'Item ${index + 1}');

  Future refresh() async {
    setState(() {
      items.clear(); //เคลียร์ข้อมูล
    });
    //ดึงข้อมูลตัวอย่างจากเว็บไซต์
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      //แปลงข้อมูล JSON เป็น List
      final List newItems = json.decode(response.body);
      setState(() {
        //กำหนดข้อมูลใส่ตัวแปร items
        items = newItems.map<String>((item) {
          final number = item['id'];
          return 'Item $number';
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pull To Refresh'),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InfiniteScrollPage())),
            icon: const Icon(Icons.arrow_circle_right_outlined),
            color: Colors.white,
            iconSize: 35,
          )
        ],
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(title: Text(item));
                },
              ),
            ),
    );
  }
}
