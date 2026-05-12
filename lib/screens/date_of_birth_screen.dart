import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../providers/language_provider.dart';

typedef OnAssessmentDobConfirmed = Future<void> Function(String dobDdMmYyyy);

class DateOfBirthScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String assessmentName;
  final String assessmentDescription;
  final Color primaryColor;
  final Color secondaryColor;
  final OnAssessmentDobConfirmed onNext;
  final VoidCallback onBack;
  /// Inclusive lower bound for date picker (e.g. 6 years ago). If null, defaults to 6 years before today.
  final DateTime? dobFirstDate;
  /// Inclusive upper bound (typically today). If null, defaults to today.
  final DateTime? dobLastDate;

  const DateOfBirthScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assessmentName,
    required this.assessmentDescription,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onNext,
    required this.onBack,
    this.dobFirstDate,
    this.dobLastDate,
  });

  @override
  State<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  DateTime? _selectedDate;
  bool _hasError = false;
  final TextEditingController _dateController = TextEditingController();

  DateTime get _firstDate {
    final now = DateTime.now();
    return widget.dobFirstDate ?? DateTime(now.year - 6, now.month, now.day);
  }

  DateTime get _lastDate {
    final t = DateTime.now();
    return widget.dobLastDate ?? DateTime(t.year, t.month, t.day);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _clampToRange(DateTime d) {
    final min = _dateOnly(_firstDate);
    final max = _dateOnly(_lastDate);
    if (d.isBefore(min)) return min;
    if (d.isAfter(max)) return max;
    return d;
  }

  bool _isValidDate(DateTime? date) {
    if (date == null) return false;
    final d = _dateOnly(date);
    final min = _dateOnly(_firstDate);
    final max = _dateOnly(_lastDate);
    return !d.isBefore(min) && !d.isAfter(max);
  }

  Future<void> _selectDate() async {
    final first = _firstDate;
    final last = _lastDate;
    final t = DateTime.now();
    final suggested = _clampToRange(DateTime(t.year - 2, t.month, t.day));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: suggested,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _hasError = false;
      });
    }
  }

  Future<void> _handleStartAssessment() async {
    if (_selectedDate == null || !_isValidDate(_selectedDate)) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    final dobStr = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    await widget.onNext(dobStr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final lang = LanguageProvider.to;
        return _buildBody(context, lang);
      }),
    );
  }

  Widget _buildBody(BuildContext context, LanguageProvider lang) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5),
              Color(0xFFFCE4EC),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFFE91E63),
                    Color(0xFF2196F3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.primaryColor.withValues(alpha: 0.1),
                                  widget.secondaryColor.withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: widget.primaryColor.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: widget.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.assessmentName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.assessmentDescription,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  Icons.access_time,
                                  lang.t('assessmentDobTimeRequiredLabel'),
                                  lang.t('assessmentDobTimeRequiredShort'),
                                  widget.primaryColor,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoItem(
                                  Icons.inventory_2_outlined,
                                  lang.t('assessmentDobMaterialsLabel'),
                                  lang.t('assessmentDobMaterialsNone'),
                                  widget.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.t('accountChildDob'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintText: lang.t('assessmentDobHintSelect'),
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: _hasError ? Colors.red : widget.primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _hasError ? Colors.red.shade400 : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _hasError ? Colors.red.shade400 : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _hasError ? Colors.red : widget.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hasError
                                ? lang.t('assessmentDobErrorInvalid')
                                : lang.t('assessmentDobAgeHelper'),
                            style: TextStyle(
                              fontSize: 12,
                              color: _hasError ? Colors.red.shade600 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isValidDate(_selectedDate)
                                  ? () => _handleStartAssessment()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.grey.shade300,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: _isValidDate(_selectedDate)
                                      ? const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFF9C27B0),
                                            Color(0xFFE91E63),
                                            Color(0xFF2196F3),
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    lang.t('assessmentDobStart'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
