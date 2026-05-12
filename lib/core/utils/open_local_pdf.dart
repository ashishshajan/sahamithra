import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Opens the PDF's parent folder in the system Files app.
Future<bool> openPdfLocation(File file) async {
  if (!await file.exists()) return false;
  final folder = file.parent;
  final folderUri = Uri.directory(folder.path);
  return launchUrl(
    folderUri,
    mode: LaunchMode.externalApplication,
  );
}
