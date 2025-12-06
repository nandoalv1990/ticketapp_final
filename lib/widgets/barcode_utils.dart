import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Builds a barcode widget wrapped in a [RepaintBoundary].
Widget buildBarcodeWidget({
  required GlobalKey barcodeKey,
  required TextEditingController controller,
  required String format,
  double size = 200,
}) {
  final barcode = getBarcodeFromFormat(format);

  return RepaintBoundary(
    key: barcodeKey,
    child: SizedBox(
      width: size,
      height: size,
      child: BarcodeWidget(
        data: controller.text,
        barcode: barcode,
        errorBuilder: (context, error) => Center(child: Text(error)),
        drawText: true,
      ),
    ),
  );
}

/// Returns a `Barcode` instance for the given [format].
Barcode getBarcodeFromFormat(String format) {
  switch (format) {
    case 'QR':
      return Barcode.qrCode();
    case 'Code 128':
      return Barcode.code128();
    case 'Aztec':
      return Barcode.aztec();
    default:
      return Barcode.qrCode();
  }
}

/// Renders the widget inside [barcodeKey] to a PNG file and returns the
/// saved file path (or null on error).
Future<String?> saveBarcodeImage(GlobalKey barcodeKey) async {
  try {
    final boundary =
        barcodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(
        pixelRatio:
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final directory = (await getApplicationDocumentsDirectory()).path;
    final path = '$directory/barcode.png';
    final file = File(path);
    await file.writeAsBytes(pngBytes);
    return path;
  } catch (_) {
    return null;
  }
}

/// Scans a barcode using the native scanner and shows a small dialog with
/// actions. Updates [controller] if the user chooses "Continuar".
Future<void> scanBarcodeAndHandle(
    BuildContext context, TextEditingController controller,
    {String defaultText = 'Escribe aqui'}) async {
  try {
    final navigator = Navigator.of(context);
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancelar',
      true,
      ScanMode.DEFAULT,
    );

    if (!navigator.mounted) return;

    if (barcode != '-1') {
      await _showOptionsDialog(navigator.context, barcode, controller);
    } else {
      controller.text = defaultText;
    }
  } catch (_) {
    // ignore errors silently to preserve previous behaviour
  }
}

Future<void> _showOptionsDialog(BuildContext context, String barcode,
    TextEditingController controller) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¿Qué quieres hacer con el código escaneado?'),
        content: Text(barcode),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Share.share(barcode);
              Navigator.of(context).pop();
            },
            child: const Text('Compartir'),
          ),
          TextButton(
            onPressed: () {
              controller.text = barcode;
              Navigator.of(context).pop();
            },
            child: const Text('Continuar'),
          ),
        ],
      );
    },
  );
}
