import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../providers/language_provider.dart';

/// Strings used when rendering the assessment PDF (localized via [LanguageProvider]).
class AssessmentPdfLabels {
  const AssessmentPdfLabels({
    required this.reportTitle,
    required this.generatedOnLabel,
    required this.sectionChildInfo,
    required this.sectionAssessmentSummary,
    required this.childLabel,
    required this.ageLabel,
    required this.ageGroupLabel,
    required this.totalScoreLabel,
    required this.percentageLabel,
    required this.zoneColorLabel,
    required this.zoneLabel,
    required this.descriptionLabel,
    required this.instructionsTitle,
    required this.questionWiseTitle,
    required this.tableQuestion,
    required this.tableAnswer,
    required this.tableExpected,
    required this.tableCorrect,
    required this.yes,
    required this.no,
    required this.footerBrand,
  });

  factory AssessmentPdfLabels.fromLang(LanguageProvider lang) {
    return AssessmentPdfLabels(
      reportTitle: lang.t('pdfReportTitle'),
      generatedOnLabel: lang.t('pdfGeneratedOn'),
      sectionChildInfo: lang.t('pdfSectionChildInfo'),
      sectionAssessmentSummary: lang.t('pdfSectionAssessmentSummary'),
      childLabel: lang.t('pdfReportChild'),
      ageLabel: lang.t('pdfReportAge'),
      ageGroupLabel: lang.t('pdfReportAgeGroup'),
      totalScoreLabel: lang.t('pdfReportTotalScore'),
      percentageLabel: lang.t('pdfReportPercentage'),
      zoneColorLabel: lang.t('pdfReportZoneColor'),
      zoneLabel: lang.t('pdfReportZone'),
      descriptionLabel: lang.t('pdfReportDescription'),
      instructionsTitle: lang.t('pdfReportInstructions'),
      questionWiseTitle: lang.t('pdfReportQuestionWise'),
      tableQuestion: lang.t('pdfTableQuestion'),
      tableAnswer: lang.t('pdfTableAnswer'),
      tableExpected: lang.t('pdfTableExpected'),
      tableCorrect: lang.t('pdfTableCorrect'),
      yes: lang.t('yes'),
      no: lang.t('no'),
      footerBrand: lang.t('pdfFooterBrand'),
    );
  }

  final String reportTitle;
  final String generatedOnLabel;
  final String sectionChildInfo;
  final String sectionAssessmentSummary;
  final String childLabel;
  final String ageLabel;
  final String ageGroupLabel;
  final String totalScoreLabel;
  final String percentageLabel;
  final String zoneColorLabel;
  final String zoneLabel;
  final String descriptionLabel;
  final String instructionsTitle;
  final String questionWiseTitle;
  final String tableQuestion;
  final String tableAnswer;
  final String tableExpected;
  final String tableCorrect;
  final String yes;
  final String no;
  final String footerBrand;
}

PdfColor _accentFromZoneColor(String? raw) {
  final c = raw?.toLowerCase().trim() ?? '';
  if (c.contains('red')) return PdfColors.red700;
  if (c.contains('green')) return PdfColors.green700;
  if (c.contains('yellow') || c.contains('amber')) return PdfColors.amber900;
  if (c.contains('orange')) return PdfColors.orange800;
  return PdfColors.blueGrey700;
}

class _PdfFonts {
  const _PdfFonts({
    required this.base,
    required this.bold,
    required this.fallbackMalayalam,
  });

  final pw.Font base;
  final pw.Font bold;
  final pw.Font fallbackMalayalam;
}

_PdfFonts? _cachedPdfFonts;

Future<_PdfFonts> _loadPdfFonts() async {
  if (_cachedPdfFonts != null) return _cachedPdfFonts!;

  final baseData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
  final boldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
  final mlData =
      await rootBundle.load('assets/fonts/NotoSansMalayalam-Regular.ttf');

  _cachedPdfFonts = _PdfFonts(
    base: pw.Font.ttf(baseData),
    bold: pw.Font.ttf(boldData),
    fallbackMalayalam: pw.Font.ttf(mlData),
  );
  return _cachedPdfFonts!;
}

/// Builds a printable PDF from the API `data` object (child, test, zone, questions).
Future<Uint8List> buildAssessmentReportPdf({
  required Map<String, dynamic> payload,
  required AssessmentPdfLabels labels,
}) async {
  final fonts = await _loadPdfFonts();
  final child = payload['child'] is Map
      ? Map<String, dynamic>.from(payload['child'] as Map)
      : <String, dynamic>{};
  final test = payload['test'] is Map
      ? Map<String, dynamic>.from(payload['test'] as Map)
      : <String, dynamic>{};
  final zone = payload['zone'] is Map
      ? Map<String, dynamic>.from(payload['zone'] as Map)
      : <String, dynamic>{};
  final questionsRaw = payload['questions'];
  final questions = questionsRaw is List
      ? questionsRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : <Map<String, dynamic>>[];

  final accent = _accentFromZoneColor(test['zone_color']?.toString());
  final instructionsRaw = zone['instructions'];
  final instructions =
      instructionsRaw is List ? instructionsRaw : const <dynamic>[];

  final generated =
      DateFormat.yMMMd().add_jm().format(DateTime.now());

  pw.Widget kvRow(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 118,
              child: pw.Text(
                k,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );

  pw.Widget sectionBox({
    required String title,
    required List<pw.Widget> children,
  }) =>
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
          borderRadius: pw.BorderRadius.circular(6),
          color: PdfColors.grey100,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 11.5,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
            pw.Divider(thickness: 0.6, color: PdfColors.grey400),
            ...children,
          ],
        ),
      );

  final instructionWidgets = <pw.Widget>[
    if (instructions.isEmpty)
      pw.Text('—', style: const pw.TextStyle(fontSize: 10))
    else ...[
      pw.SizedBox(height: 2),
      ...instructions.asMap().entries.map((e) {
        final i = e.value;
        if (i is Map) {
          final m = Map<String, dynamic>.from(i);
          final title = (m['title'] ?? '').toString().trim();
          final desc = (m['description'] ?? '').toString().trim();
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${e.key + 1}. ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        title.isEmpty ? '—' : title,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (desc.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14, top: 3),
                    child: pw.Text(
                      desc,
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
              ],
            ),
          );
        }
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            '${e.key + 1}. ${i.toString()}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        );
      }),
    ],
  ];

  final tableHeaderStyle = pw.TextStyle(
    fontSize: 9.5,
    fontWeight: pw.FontWeight.bold,
  );
  final cellStyle = const pw.TextStyle(fontSize: 9);

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: fonts.base,
      bold: fonts.bold,
      fontFallback: [fonts.fallbackMalayalam],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.fromLTRB(26, 22, 26, 20),
          decoration: pw.BoxDecoration(color: accent),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                labels.reportTitle,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '${labels.generatedOnLabel} $generated',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 9),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 22, 28, 28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              sectionBox(
                title: labels.sectionChildInfo,
                children: [
                  kvRow(labels.childLabel, '${child['name'] ?? '—'}'),
                  kvRow(labels.ageLabel, '${child['age'] ?? '—'}'),
                  kvRow(labels.ageGroupLabel, '${child['age_group'] ?? '—'}'),
                ],
              ),
              pw.SizedBox(height: 14),
              sectionBox(
                title: labels.sectionAssessmentSummary,
                children: [
                  kvRow(labels.totalScoreLabel, '${test['total_score'] ?? '—'}'),
                  kvRow(labels.percentageLabel, '${test['percentage'] ?? '—'}'),
                  kvRow(labels.zoneColorLabel, '${test['zone_color'] ?? '—'}'),
                  kvRow(labels.zoneLabel, '${zone['label'] ?? '—'}'),
                  kvRow(labels.descriptionLabel, '${zone['description'] ?? '—'}'),
                ],
              ),
              pw.SizedBox(height: 14),
              sectionBox(
                title: labels.instructionsTitle,
                children: instructionWidgets,
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                labels.questionWiseTitle,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey500,
                  width: 0.4,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _pdfCell(labels.tableQuestion, tableHeaderStyle),
                      _pdfCell(labels.tableAnswer, tableHeaderStyle),
                      _pdfCell(labels.tableExpected, tableHeaderStyle),
                      _pdfCell(labels.tableCorrect, tableHeaderStyle),
                    ],
                  ),
                  ...questions.asMap().entries.map((entry) {
                    final q = entry.value;
                    final stripe = entry.key.isEven ? PdfColors.white : PdfColors.grey50;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: stripe),
                      children: [
                        _pdfCell(
                          '${q['question'] ?? ''}',
                          cellStyle,
                          align: pw.Alignment.centerLeft,
                        ),
                        _pdfCell('${q['answer'] ?? ''}', cellStyle),
                        _pdfCell('${q['expected'] ?? ''}', cellStyle),
                        _pdfCell(
                          (q['is_correct'] == true) ? labels.yes : labels.no,
                          cellStyle,
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Center(
                child: pw.Text(
                  labels.footerBrand,
                  style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return Uint8List.fromList(await pdf.save());
}

pw.Widget _pdfCell(
  String text,
  pw.TextStyle style, {
  pw.Alignment align = pw.Alignment.center,
}) {
  return pw.Container(
    alignment: align,
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    child: pw.Text(text, style: style),
  );
}
