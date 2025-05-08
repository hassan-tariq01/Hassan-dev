import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

const String apiUrl = 'http://192.168.72.254:5000/item'; // Try this first// Replace with your backend URL

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ItemPage(),
    );
  }
}

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});
  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<String> items = [];
  final TextEditingController controller = TextEditingController();

  Future<void> fetchItems() async {
    final res = await http.get(Uri.parse(apiUrl));
    final List data = json.decode(res.body);
    setState(() {
      items = data.map((item) => item['name'] as String).toList();
    });
  }

  Future<void> addItem(String name) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      ).timeout(Duration(seconds: 5));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        fetchItems();
        controller.clear();
      } else {
        throw Exception('Server responded with ${response.statusCode}');
      }
    } catch (e) {
      print('Full error details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MongoDB + Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Enter item'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => addItem(controller.text),
              child: const Text('Add'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: items.map((e) => ListTile(title: Text(e))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}