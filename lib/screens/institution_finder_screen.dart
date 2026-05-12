import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';
import '../routes/app_routes.dart';

/// Mirrors /components/InstitutionFinderScreen.tsx
/// Updated to fetch dynamic data from API and use "Institution" label.
class InstitutionFinderScreen extends StatefulWidget {
  const InstitutionFinderScreen({super.key});

  @override
  State<InstitutionFinderScreen> createState() => _InstitutionFinderScreenState();
}

class _InstitutionFinderScreenState extends State<InstitutionFinderScreen> {
  static const double _nearbyRadiusKm = 40;
  List<dynamic> _institutions = [];
  bool _isLoading = true;
  String? _loadErrorKey;
  String? _loadErrorDetail;

  @override
  void initState() {
    super.initState();
    _fetchInstitutions();
  }

  Future<void> _fetchInstitutions() async {
    setState(() {
      _isLoading = true;
      _loadErrorKey = null;
      _loadErrorDetail = null;
    });

    final token = GlobalUtils().token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _loadErrorKey = 'errorAuthTokenNotFound';
      });
      return;
    }

    final position = await _resolveCurrentPosition();
    if (position == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadErrorKey = 'institutionsLoadFailed';
        _loadErrorDetail = 'Location permission denied or unavailable';
      });
      return;
    }

    final nearbyResult = await NetworkHelper().getNearbyTherapyCentres(
      latitude: position.latitude,
      longitude: position.longitude,
      radius: _nearbyRadiusKm,
    );

    List<dynamic> institutions = _extractInstitutionsFromResult(nearbyResult);
    bool usedFallback = false;

    if (institutions.isEmpty) {
      final fallback = await NetworkHelper().getTherapyCentres();
      institutions = _extractInstitutionsFromResult(fallback);
      usedFallback = true;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (institutions.isNotEmpty) {
          _institutions = institutions;
        } else if (nearbyResult['success'] == true || usedFallback) {
          _institutions = const [];
        } else {
          _loadErrorKey = 'institutionsLoadFailed';
          final msg = nearbyResult['message']?.toString();
          _loadErrorDetail =
              (msg != null && msg.isNotEmpty) ? msg : null;
        }
      });
    }
  }

  Future<Position?> _resolveCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  List<dynamic> _extractInstitutionsFromResult(Map<String, dynamic> result) {
    if (result['success'] != true) return const [];
    final payload = result['data'];
    if (payload is List) return payload;

    // Handle multiple backend response shapes safely without indexing into
    // non-map values (which caused "String is not a subtype of int of index").
    if (payload is Map) {
      final nestedData = payload['data'];
      if (nestedData is List) return nestedData;
      if (nestedData is Map) {
        final deeplyNested = nestedData['data'];
        if (deeplyNested is List) return deeplyNested;
      }
    }

    final topLevelNested = result['payload'];
    if (topLevelNested is List) return topLevelNested;
    if (topLevelNested is Map) {
      final list = topLevelNested['data'];
      if (list is List) return list;
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;

      String loadErrorText() {
        if (_loadErrorKey == null) return '';
        final base = lang.t(_loadErrorKey!);
        if (_loadErrorDetail != null && _loadErrorDetail!.isNotEmpty) {
          return '$base — $_loadErrorDetail';
        }
        return base;
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title: lang.t('institutionsNearYouTitle'),
              subtitle: lang.t('institutionsNearYouSubtitle'),
            ),

            // Map preview teaser
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.neutral200.withValues(alpha: 0.8)),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 40.sp,
                      color: AppColors.purple,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      lang.t('institutionsGpsMapView'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (!_isLoading)
                      Text(
                        lang
                            .t('institutionsNearbyCount')
                            .replaceAll('{count}', '${_institutions.length}'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _buildContent(lang, loadErrorText),
            ),
            const StandardFooter(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(LanguageProvider lang, String Function() loadErrorText) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadErrorKey != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loadErrorText(),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.error, fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              GradientTextButton(
                label: lang.t('retry'),
                onPressed: _fetchInstitutions,
                height: 50.h,
              ),
            ],
          ),
        ),
      );
    }

    if (_institutions.isEmpty) {
      return Center(
        child: Text(
          lang.t('institutionsNoneNearby'),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.base.r),
      separatorBuilder: (context, _) => SizedBox(height: 12.h),
      itemCount: _institutions.length,
      itemBuilder: (_, i) {
        final raw = _institutions[i];
        if (raw is! Map) return const SizedBox.shrink();
        return _InstitutionCard(data: Map<String, dynamic>.from(raw));
      },
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  const _InstitutionCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = LanguageProvider.to;
      final _ = lang.language;
      return _buildCard(lang);
    });
  }

  Widget _buildCard(LanguageProvider lang) {
    final location = data['location'] ?? {};
    final services = _extractServices(data);

    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? lang.t('institutionDefaultName'),
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 2.h),
                    Text(data['type'] ?? lang.t('institutionTherapyCenter'),
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.purple100,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 14.sp, color: Colors.amber),
                    SizedBox(width: 3.w),
                    Text((data['rating'] ?? 5.0).toString(),
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _InfoRow(
              Icons.location_on_rounded,
              location['address'] ?? lang.t('institutionAddressUnavailable'),
              _formatDistance(data['distance'])),
          SizedBox(height: 6.h),
          _InfoRow(Icons.phone_rounded,
              data['phone'] ?? lang.t('institutionPhoneUnavailable'), null),
          SizedBox(height: 6.h),
          _InfoRow(
              Icons.access_time_rounded,
              data['hours'] ?? lang.t('institutionHoursUnavailable'),
              null),
          SizedBox(height: 12.h),

          if (services.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: services
                  .map((s) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.blue100,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 11.sp, color: AppColors.blue600)),
                      ))
                  .toList(),
            ),
            SizedBox(height: 12.h),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 48.h),
                    side: const BorderSide(color: AppColors.neutral300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Text(
                    lang.t('getDirections'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GradientButton(
                  onPressed: () => Get.toNamed(
                    AppRoutes.appointments,
                    arguments: data,
                  ),
                  height: 48.h,
                  child: Text(
                    lang.t('institutionBookAppointment'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _extractServices(Map<String, dynamic> data) {
    final specialitiesRaw = data['specialities'];
    if (specialitiesRaw is List) {
      final values = specialitiesRaw
          .whereType<Map>()
          .map((e) => e['name']?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (values.isNotEmpty) return values;
    }
    final servicesRaw = data['services'];
    if (servicesRaw is List) {
      return servicesRaw
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  String? _formatDistance(dynamic distance) {
    if (distance == null) return null;
    if (distance is num) {
      return '${distance.toStringAsFixed(1)} km';
    }
    final parsed = double.tryParse(distance.toString());
    if (parsed == null) return null;
    return '${parsed.toStringAsFixed(1)} km';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text, this.trailing);
  final IconData icon;
  final String text;
  final dynamic trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: 6.w),
        Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.sp, color: AppColors.textSecondary))),
        if (trailing != null)
          Text(
            '$trailing',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
