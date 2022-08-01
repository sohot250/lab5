import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfiniteScrollPage extends StatefulWidget {
  const InfiniteScrollPage({Key? key}) : super(key: key);

  @override
  State<InfiniteScrollPage> createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  final controller = ScrollController();
  List<String> items = []; //ข้อมูลที่ใช้แสดงบนหน้าจอ
  bool hasMore = true; //ใช้ตรวจสอบว่ามีข้อมูลอีกหรือไม่
  int page = 1; //กำหนดดึงข้อมูลที่หน้าแรก
  bool isLoading = false; //ใช้ตรวจสอบไม่ให้ดึงข้อมูลซ้ำๆ

  @override
  void initState() {
    super.initState();

    fetch();

    controller.addListener(() {
      //หากเลื่อนหน้าจอถึงด้านล่างสุดจะเรียกเมธอด fetch() เพื่อดึงข้อมูลเพิ่ม
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future fetch() async {
    if (isLoading) return;
    isLoading = true;

    const limit = 25; //ดึงข้อมูลครั้งละ 25 รายการ
    //ดึงข้อมูลตัวอย่างจากเว็บไซต์
    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      //แปลงข้อมูล JSON เป็น List
      final List newItems = json.decode(response.body);

      setState(() {
        page++; //เรียกหน้าถัดไป
        isLoading = false;

        //หากขนาดข้อมูลน้อยกว่า limit จะไม่ดึงข้อมูลอีก
        if (newItems.length < limit) {
          hasMore = false;
        }

        //กำหนดข้อมูลใส่ตัวแปร items
        items.addAll(newItems.map<String>((item) {
          final number = item['id'];
          return 'Item $number';
        }).toList());
      });
    }
  }

  Future refresh() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 1;
      items.clear(); //เคลียร์ข้อมูล
    });

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scrolling ListView'),
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(8),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    final item = items[index];
                    return ListTile(title: Text(item));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: hasMore
                            ? const CircularProgressIndicator()
                            : const Text('No more data to load'),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }
}
