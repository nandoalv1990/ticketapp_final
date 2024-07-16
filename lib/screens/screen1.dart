import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'screen2.dart';
import 'screen3.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  Screen1State createState() => Screen1State();
}

class Screen1State extends State<Screen1> {
  String selectedFormat = 'QR';
  final items = ['QR', 'Code 128', 'Aztec'];
  final text1 = 'Escribe aqui';
  TextEditingController textController = TextEditingController();
  List<Map<String, String>> products = [];

  @override
  void initState() {
    super.initState();
    textController.text = text1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TicketFlutter 1.0'),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Screen2(
                    key: UniqueKey(),
                    initialLabelText: textController.text,
                    initialFormat: selectedFormat,
                    barcodeImage: '',
                    products: products,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.print),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Screen3(),
                ),
              );
              if (result != null) {
                setState(() {
                  products = List<Map<String, String>>.from(result);
                });
              }
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Selecciona el formato de código de barras:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                items: items
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                value: selectedFormat,
                onChanged: (value) => setState(() => selectedFormat = value!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Texto a convertir',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: generateBarcode,
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: scanBarcode,
                child: const Text('Escanear'),
              ),
              const SizedBox(height: 20),
              buildBarcodeWidget(selectedFormat),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey barcodeKey = GlobalKey();
  Widget buildBarcodeWidget(String format) {
    Barcode barcode;
    switch (format) {
      case 'QR':
        barcode = Barcode.qrCode();
        break;
      case 'Code 128':
        barcode = Barcode.code128();
        break;
      case 'Aztec':
        barcode = Barcode.aztec();
        break;
      default:
        barcode = Barcode.qrCode();
        break;
    }

    return RepaintBoundary(
      key: barcodeKey,
      child: SizedBox(
        width: 200,
        height: 200,
        child: BarcodeWidget(
          data: textController.text,
          barcode: barcode,
          errorBuilder: (context, error) => Center(child: Text(error)),
          drawText: true,
        ),
      ),
    );
  }

  Future<void> generateBarcode() async {
    try {
      RenderRepaintBoundary boundary = barcodeKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      File imgFile = File('$directory/barcode.png');
      imgFile.writeAsBytes(pngBytes);

      //print('Barcode saved to $directory/barcode.png');
    } catch (e) {
      //print('Error generating barcode: $e');
    }
  }

  Future<void> scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.DEFAULT,
      );

      if (barcode != '-1') {
        _showOptionsDialog(barcode);
      } else {
        setState(() {
          textController.text = text1;
        });
      }
    } catch (e) {
      //print('Error scanning barcode: $e');
    }
  }

  void _showOptionsDialog(String barcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Qué quieres hacer con el código escaneado?'),
          content: Text(barcode),
          actions: <Widget>[
            /* TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Uri uri = Uri.parse(barcode);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  //print('Could not launch $barcode');
                }
              },
              child: const Text('Abrir'),
            ),*/
            TextButton(
              onPressed: () {
                Share.share(barcode);
                Navigator.of(context).pop();
              },
              child: const Text('Compartir'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  textController.text = barcode;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }
}
