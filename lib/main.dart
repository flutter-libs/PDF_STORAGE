import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: PdfStoragePage(),
    );
  }
}
class PdfStoragePage extends StatefulWidget {
  @override
  _PdfStoragePageState createState() => _PdfStoragePageState();
}
class _PdfStoragePageState extends State<PdfStoragePage> {
List<File> pdfFiles = [];

@override
void initState() {
  super.initState();
  _loadPdfFiles();
}

Future<void> _loadPdfFiles() async {
  final directory = await getApplicationDocumentsDirectory();
  final pdfDir = Directory("${directory.path}/pdfs");
  if (await pdfDir.exists()) {
    setState(() {
      pdfFiles = pdfDir.listSync().map((item) => File(item.path)).toList();
    });
  } else {
    await pdfDir.create();
  }
}

Future<void> _pickAndStorePdf() async {
  // Request storage permission
  PermissionStatus permission = await Permission.storage.request();
  if (!permission.isGranted) {
    print("Permission Denied");
    return;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null && result.files.single.path != null) {
    File pdfFile = File(result.files.single.path!);

    // Copy the file to the app's directory
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory("${directory.path}/pdfs");
    String newPath = "${pdfDir.path}/${result.files.single.name}";
    File newFile = await pdfFile.copy(newPath);

    setState(() {
      pdfFiles.add(newFile);
    });
  }
}

void _viewPdf(File file) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewPage(pdfFile: file),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("PDF Storage App"),
    ),
    body: ListView.builder(
      itemCount: pdfFiles.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.picture_as_pdf),
          title: Text(pdfFiles[index].path.split('/').last),
          onTap: () => _viewPdf(pdfFiles[index]),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: _pickAndStorePdf,
    ),
  );
}
}

class PdfViewPage extends StatelessWidget {
  final File pdfFile;

  PdfViewPage({required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: PDFView(
        filePath: pdfFile.path,
      ),
    );
  }
}