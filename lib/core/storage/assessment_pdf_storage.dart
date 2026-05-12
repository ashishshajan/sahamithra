import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart';

/// Folder name inside the platform Downloads area (and as a fallback under app Documents).
const String assessmentPdfFolderName = 'Sahamitra';

Future<List<Directory>> _candidateAssessmentPdfDirectories() async {
  final ordered = <Directory>[];
  final seen = <String>{};

  void addDir(Directory d) {
    final p = d.path;
    if (p.isEmpty || seen.contains(p)) return;
    seen.add(p);
    ordered.add(d);
  }

  // Prefer …/Download/Sahamitra (Android public Downloads; iOS sandbox Downloads).
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final root = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
      if (root.isNotEmpty) {
        addDir(Directory('$root/$assessmentPdfFolderName'));
      }
    } catch (_) {}
  }

  // Android scoped app external Downloads (no extra permission on modern APIs).
  if (Platform.isAndroid) {
    try {
      final scoped = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (scoped != null && scoped.isNotEmpty) {
        addDir(Directory('${scoped.first.path}/$assessmentPdfFolderName'));
      }
    } catch (_) {}
  }

  try {
    final doc = await getApplicationDocumentsDirectory();
    addDir(Directory('${doc.path}/$assessmentPdfFolderName'));
  } catch (_) {}

  return ordered;
}

/// Writes PDF bytes to the first writable location:
/// `Download/Sahamitra` when allowed, then scoped Downloads/Sahamitra on Android,
/// then `Documents/Sahamitra`.
Future<File> saveAssessmentReportPdfFile({
  required List<int> bytes,
  required int childId,
}) async {
  final fileName =
      'assessment_report_${childId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  final candidates = await _candidateAssessmentPdfDirectories();

  Object? lastError;
  for (final dir in candidates) {
    try {
      await dir.create(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      lastError = e;
    }
  }

  throw StateError('Could not save PDF: $lastError');
}
