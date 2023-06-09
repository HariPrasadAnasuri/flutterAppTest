import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import 'manage_photos.dart';

class ShowQrCodePhoto extends StatefulWidget {
  const ShowQrCodePhoto({super.key});

  @override
  State<ShowQrCodePhoto> createState() => _ShowQrCodePhotoState();
}

class _ShowQrCodePhotoState extends State<ShowQrCodePhoto> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  Future<bool> updateFileId() async {
    var photoInfoUuidUrl = Uri.parse(AppValues.getUrlForToGetFileByUuid());
    debugPrint("Url to get the  photoID: $photoInfoUuidUrl");
    var photoInfoUuidResponse = await http.get(photoInfoUuidUrl);
    AppValues.fileId = jsonDecode(photoInfoUuidResponse.body)["id"];
    return true;
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                  'Barcode Type: ---   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          ),
          Expanded(child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              /*Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    AppValues.uuid = result!.code!;
                    return const SelectedPhotos();
                  },
                ),
              );*/
              debugPrint("Before calling API");
              AppValues.uuid = result!.code!;
              await updateFileId();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    return const ManagePhotos();
                  },
                ),
              );
            },
            child: const Text('Selected photos'),
          ),)
        ],
      ),
    );
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
