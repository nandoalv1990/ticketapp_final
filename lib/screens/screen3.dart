import 'package:flutter/material.dart';
import 'db_helper.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  List<Map<String, dynamic>> products = [];
  final TextEditingController productController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _refreshProductList();
  }

  void _refreshProductList() async {
    final data = await dbHelper.getProductMapList();
    setState(() {
      products = data;
    });
  }

  void _addProduct() async {
    if (productController.text.isEmpty || codeController.text.isEmpty) return;
    await dbHelper.insertProduct({
      'product': productController.text,
      'code': codeController.text,
    });
    productController.clear();
    codeController.clear();
    _refreshProductList();
  }

  void _deleteProduct(int id) async {
    await dbHelper.deleteProduct(id);
    _refreshProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: productController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del producto'),
            ),
            TextField(
              controller: codeController,
              decoration:
                  const InputDecoration(labelText: 'Código del producto'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Agregar producto'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(products[index]['product'] ?? ''),
                    subtitle: Text(products[index]['code'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(products[index]['id']),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, products);
              },
              child: const Text('Guardar configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
