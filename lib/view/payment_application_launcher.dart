import 'package:flutter/material.dart';
import 'package:orderkar/common/extension.dart';
import 'package:orderkar/common/globs.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Payment_application_Screen extends StatefulWidget {
  @override
  _Payment_application_ScreenState createState() =>
      _Payment_application_ScreenState();
}

class _Payment_application_ScreenState
    extends State<Payment_application_Screen> {
  late final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("QR Code Scanner"),
        ),
        body: MobileScanner(
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
          ),
          onDetect: (capture) {
            List<Barcode> barcodes = capture.barcodes;
            _launchURL(barcodes.first.rawValue);
            print("uri: ${barcodes.first.rawValue}  ");
          },
        ));
  }

  Future<void> _launchURL(String? url) async {
    Uri uri = Uri.parse(url!);
    print("uri: $uri  ");
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    } else {
      mdShowAlert(Globs.appName, "Could not launch url", () {});
    }
  }
}
