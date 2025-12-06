import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/barcode_utils.dart';
import 'package:pdf/pdf.dart';

/// Prints a PDF document containing the [labelText], an inline barcode using
/// [selectedFormat], optional [barcodeImage] and a list of [products].
Future<void> printDocument(
  BuildContext context,
  String labelText,
  String selectedFormat,
  String barcodeImage,
  List<Map<String, String>> products,
) async {
  final pdf = pw.Document();

  final barcode = getBarcodeFromFormat(selectedFormat);

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              labelText,
              style: const pw.TextStyle(fontSize: 40),
            ),
            pw.SizedBox(height: 20),
            pw.BarcodeWidget(
              barcode: barcode,
              data: labelText,
              width: 200,
              height: 200,
              drawText: false,
            ),
            pw.SizedBox(height: 20),
            for (var product in products)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Producto: ${product['product'] ?? ''}'),
                  pw.Text('Código: ${product['code'] ?? ''}'),
                  pw.SizedBox(height: 10),
                ],
              ),
            if (barcodeImage.isNotEmpty)
              pw.Column(children: [
                pw.SizedBox(height: 10),
                pw.Text('Imagen del código (adjunta):'),
              ]),
          ],
        );
      },
    ),
  );

  final messenger = ScaffoldMessenger.of(context);
  try {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Error al imprimir el documento PDF: $e')),
    );
  }
}
