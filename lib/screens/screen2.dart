import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/label_printer.dart' as label_printer;

class Screen2 extends StatefulWidget {
  final String initialLabelText;
  final String initialFormat;
  final String barcodeImage;
  final List<Map<String, String>> products;

  const Screen2({
    required Key key,
    required this.initialLabelText,
    required this.initialFormat,
    required this.barcodeImage,
    required this.products,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  late String labelText;
  late String selectedFormat;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    labelText = widget.initialLabelText;
    selectedFormat = widget.initialFormat;
    textController = TextEditingController(text: widget.initialLabelText);
  }

  @override
  Widget build(BuildContext context) {
    const jump = SizedBox(height: 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseñar etiqueta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Texto de la etiqueta',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  labelText = value;
                });
              },
            ),
            jump,
            ElevatedButton(
              onPressed: printDocument,
              child: const Text('Imprimir'),
            ),
            jump,
            Text(
              'Texto de la etiqueta: $labelText',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (widget.barcodeImage.isNotEmpty)
              Image.file(
                File(widget.barcodeImage),
                width: 200,
                height: 200,
              ),
            const SizedBox(height: 20),
            for (var product in widget.products)
              ListTile(
                title: Text(product['product'] ?? ''),
                subtitle: Text(product['code'] ?? ''),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> printDocument() async {
    await label_printer.printDocument(context, labelText, selectedFormat,
        widget.barcodeImage, widget.products);
  }
}
