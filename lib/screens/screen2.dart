import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Screen2 extends StatefulWidget {
  final String initialLabelText;
  final String initialFormat;
  final String barcodeImage;

  const Screen2({
    required Key key,
    required this.initialLabelText,
    required this.initialFormat,
    required this.barcodeImage,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  String labelText = '';
  String selectedFormat = '';

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    labelText = widget.initialLabelText;
    selectedFormat = widget.initialFormat;
    textController.text = widget.initialLabelText;
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
              Image.network(
                widget.barcodeImage,
                width: 200,
                height: 200,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> printDocument() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Text(
              labelText,
              style: const pw.TextStyle(fontSize: 40),
            ),
          );
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/ticket.pdf');

    await tempFile.writeAsBytes(pdf.save() as List<int>);

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => await pdf.save(),
      );
    } catch (e) {
      //print('Error al imprimir el documento PDF: $e');
    }

    try {
      await tempFile.delete();
    } catch (e) {
      //print('Error al eliminar el archivo PDF: $e');
    }
  }
}
