import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:barcode_image/barcode_image.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// ignore: unused_import
import 'package:printing/printing.dart';
// ignore: unused_import
import 'package:pdf/pdf.dart';
// ignore: unused_import
import 'package:pdf/widgets.dart' as pw;
import 'screen2.dart';
// ignore: unused_import
import 'package:logger/logger.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  Screen1State createState() => Screen1State();
}

class Screen1State extends State<Screen1> {
  String selectedFormat = '';

  final items = ['QR', 'Code 128', 'Aztec'];

  final text1 = 'Escribe aqui';

  final space1 = const SizedBox(height: 10);

  final space2 = const SizedBox(height: 20);

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedFormat = (items.isNotEmpty ? items.first : null)!;
    textController.text = text1; // Establecer el texto por defecto
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TicketFlutter 1.0'),
        backgroundColor: Colors.white,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final imagePath =
                      await generateBarcode(); // Esperar a que generateBarcode() termine
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => Screen2(
                        key: UniqueKey(),
                        initialLabelText: textController.text,
                        initialFormat: selectedFormat,
                        barcodeImage: imagePath ?? '',
                      ),
                    ),
                  ).then((modifiedInfo) {
                    if (modifiedInfo != null) {
                      textController.text =
                          modifiedInfo['text'] ?? textController.text;
                      selectedFormat = modifiedInfo['format'] ?? selectedFormat;
                    }
                  });
                },
                icon: const Icon(Icons.print),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              space2,
              const Text(''),
              space2,
              const Text(
                'Selecciona el formato de código de barras:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              space1,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 100,
                    child: DropdownButton<String>(
                      items: items
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      value: selectedFormat,
                      onChanged: (value) =>
                          setState(() => selectedFormat = value!),
                    ),
                  ),
                ],
              ),
              space2,
              SizedBox(
                width: 250,
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      //hintText: 'Ejemplo: Hola Mundo',
                      labelText: 'Texto a convertir',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              space2,
              ElevatedButton(
                onPressed: () => generateBarcode(),
                child: const Text('Guardar'),
              ),
              space2,
              ElevatedButton(
                onPressed: () => scanBarcode(),
                child: const Text('Escanear'),
              ),
              space2,
              buildBarcodeWidget(selectedFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBarcodeWidget(String format) {
    Barcode? barcode;
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

    //barcode ??= Barcode.qrCode();

    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: BarcodeWidget(
        data: textController.text,
        barcode: barcode,
        errorBuilder: (context, error) => Center(child: Text(error)),
        drawText: true,
      ),
    );
  }

  Future<String?> generateBarcode() async {
    if (textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Por favor, ingresa una serie antes de generar el código de barras'),
      ));
      return null;
    }

    Barcode? barcode;
    switch (selectedFormat) {
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
        throw Exception('Formato de código no reconocido');
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final image = await generateBarcodeImage(barcode);
    if (image != null) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Codigo de barras generado y guardado como imagen'),
      ));
      final imagePath = await saveImage(image);
      return imagePath;
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Error al generar el codigo de barras'),
      ));
      return null;
    }
  }

  Future<img.Image?> generateBarcodeImage(Barcode barcode) async {
    try {
      if (textController.text.isEmpty) {
        return null; // Retorna null si el campo de texto está vacío
      }
      final image = img.Image(width: 200, height: 100);

      drawBarcode(image, barcode, 'Test', width: 200);
      return image;
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('Error generating barcode image: $e');
      // ignore: avoid_print
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  Future<String?> saveImage(img.Image image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/barcode.png';

      // Guardar la imagen en formato PNG
      File(imagePath).writeAsBytesSync(img.encodePng(image));

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Image.memory(
                img.encodePng(image)), // Muestra la imagen en un diálogo
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // ignore: unused_local_variable
      final result = await ImageGallerySaver.saveFile(imagePath);
      //print('Image saved: $result');
      return imagePath;
    } catch (e) {
      //print('Error saving image: $e');
      //throw e;
    }
    return null;
  }

  Future<void> scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', //color
        'Cancelar', //text
        true, //flash icon
        ScanMode.DEFAULT, //scan mode
      );

      if (barcode != '-1') {
        setState(() {
          textController.text = barcode; //?? '';
        });
      } else {
        setState(() {
          textController.text = text1;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error scanning barcode: $e');
    }
  }
}
