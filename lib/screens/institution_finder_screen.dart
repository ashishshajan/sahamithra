import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
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
  List<dynamic> _institutions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInstitutions();
  }

  Future<void> _fetchInstitutions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = GlobalUtils().token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Authentication token not found';
      });
      return;
    }

    final result = await NetworkHelper().getTherapyCentres();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _institutions = result['data']?['data']?['data'] ?? [];
        } else {
          _error = result['message'] ?? 'Failed to load institutions';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.green600,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16.sp, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text('Institutions Near You',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          // Map preview teaser
          Container(
            height: 140.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD1FAE5), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 40.sp, color: AppColors.green600),
                      SizedBox(height: 8.h),
                      Text('GPS Map View',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary)),
                      if (!_isLoading)
                        Text('Showing ${_institutions.length} institutions nearby',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildContent(),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 14.sp)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _fetchInstitutions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_institutions.isEmpty) {
      return Center(
        child: Text('No institutions found nearby',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.base.r),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemCount: _institutions.length,
      itemBuilder: (_, i) => _InstitutionCard(data: _institutions[i]),
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  const _InstitutionCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final location = data['location'] ?? {};
    final services = List<String>.from(data['services'] ?? []);

    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
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
                    Text(data['name'] ?? 'Institution',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 2.h),
                    Text(data['type'] ?? 'Therapy Center',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
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

          _InfoRow(Icons.location_on_rounded, location['address'] ?? 'Address unavailable', data['distance']),
          SizedBox(height: 6.h),
          _InfoRow(Icons.phone_rounded, data['phone'] ?? 'Phone unavailable', null),
          SizedBox(height: 6.h),
          _InfoRow(Icons.access_time_rounded, data['hours'] ?? 'Timing unavailable', null),
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
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/appointments', arguments: data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green600,
                    minimumSize: Size(0, 42.h),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl)),
                  ),
                  child: Text('Book Appointment',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 42.h),
                    side: const BorderSide(color: AppColors.neutral300),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl)),
                  ),
                  child: Text('Get Directions',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          Text('$trailing',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.green600,
                  fontWeight: FontWeight.w500)),
      ],
    );
  }
}
