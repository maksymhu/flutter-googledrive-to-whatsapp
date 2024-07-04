import 'dart:io';

// import 'package:example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googledrivehandler/googledrivehandler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      options: const FirebaseOptions(
    apiKey: 'AIzaSyC0oxpeyRKq2xnpL0nY8L7Ea4ZwjfwLWxE',
    appId: '1:573738276744:android:dc2051423fafe5a4334c3d',
    messagingSenderId: '573738276744',
    projectId: 'gdrive-428115',
    storageBucket: 'gdrive-428115.appspot.com',
  ));
  runApp(
    const GoogleDriveDownloadApp(),
  );
}

class GoogleDriveDownloadApp extends StatelessWidget {
  const GoogleDriveDownloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  final String myApiKey = "AIzaSyC0oxpeyRKq2xnpL0nY8L7Ea4ZwjfwLWxE";

  Future<String> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> folders = directory!.path.split("/");
        for (int i = 1; i < folders.length; i++) {
          String folder = folders[i];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        directory = Directory(newPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (err) {
      print("Cannot get download folder path: $err");
    }
    return directory?.path ?? "";
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> shareFile(File file) async {

    await WhatsappShare.shareFile(
      phone: '911234567890',
      filePath: [file.path],
    );
  }

  Future<void> isInstalled() async {
    final val = await WhatsappShare.isInstalled(package: Package.whatsapp);
    debugPrint('Whatsapp is installed: $val');
  }

  @override
  Widget build(BuildContext context) {
    GoogleDriveHandler().setAPIKey(
      apiKey: myApiKey,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Google Drive Download",
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Directory? downloadDirectory = await getDownloadsDirectory();
                await _requestPermissions();
                File? myFile = await GoogleDriveHandler()
                    .getFileFromGoogleDrive(context: context);
                if (myFile != null) {
                  String downloadPath = await _getDownloadPath();
                  File downloadFile =
                      File('$downloadPath/${myFile.path.split('/').last}');
                  await downloadFile.writeAsBytes(await myFile.readAsBytes());
                  // Check if business whatsapp installed
                  isInstalled();
                  // await WhatsappShare.share(
                  //   text: 'Sharing ...',
                  //   linkUrl: 'https://flutter.dev/',
                  //   phone: '15072204636',
                  // );

                  await WhatsappShare.shareFile(
                    phone: '15072204636',
                    filePath: [downloadFile.path],
                  );
                  
                  OpenFile.open(downloadFile.path);
                  print(downloadFile.path);
                } else {
                  /// Discard...
                }
              },
              child: const Text(
                "Get file from google drive",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
