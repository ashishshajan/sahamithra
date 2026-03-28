import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/video_item.dart';
import '../widgets/gradient_header.dart';

/// Pass [Get.arguments] as either:
/// - a [VideoItem] (e.g. from [VideosListScreen]), or
/// - a `Map` with keys: `session_id`, `therapy_id`, `session_name`,
///   `instruction`, `video_url`, `thumbnail_url`, `watch_status`, `duration`.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  TherapyVideoSessionArgs? _args;
  YoutubePlayerController? _ytController;
  bool _landscapePreferred = false;

  @override
  void initState() {
    super.initState();
    _args = TherapyVideoSessionArgs.fromGetArguments();
    final id = YoutubePlayer.convertUrlToId(_args?.videoUrl ?? '') ?? '';
    if (id.length == 11) {
      _ytController = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          loop: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _restorePortraitOrientations();
    super.dispose();
  }

  void _restorePortraitOrientations() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _enterLandscape() {
    setState(() => _landscapePreferred = true);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitLandscape() {
    setState(() => _landscapePreferred = false);
    _restorePortraitOrientations();
  }

  Future<void> _openInBrowser() async {
    final url = _args?.videoUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video')),
        body: Center(
          child: Text(
            'Missing video arguments',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }

    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape ||
        _landscapePreferred;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _restorePortraitOrientations();
        }
      },
      child: Scaffold(
        backgroundColor:
            isLandscape ? Colors.black : const Color(0xFFF8FAFC),
        body: isLandscape
            ? _buildLandscapeBody(args)
            : _buildPortraitBody(args),
      ),
    );
  }

  Widget _buildLandscapeBody(TherapyVideoSessionArgs args) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: _ytController != null
              ? Center(
                  child: YoutubePlayer(
                    controller: _ytController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.purple,
                    progressColors: const ProgressBarColors(
                      playedColor: AppColors.purple,
                      handleColor: AppColors.pink600,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'Invalid YouTube URL',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _exitLandscape();
                  },
                  icon: const Icon(Icons.screen_lock_portrait_rounded,
                      color: Colors.white),
                  tooltip: 'Portrait',
                ),
                Expanded(
                  child: Text(
                    args.sessionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _restorePortraitOrientations();
                    Get.back();
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitBody(TherapyVideoSessionArgs args) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientHeader(
          onBack: () => Get.back(),
          title: args.sessionName,
          subtitle: 'Therapy video',
          trailing: IconButton(
            onPressed: _enterLandscape,
            icon: Icon(
              Icons.screen_lock_landscape_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            tooltip: 'Watch in landscape',
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.base.r),
            children: [
              if (args.thumbnailUrl != null &&
                  args.thumbnailUrl!.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                  child: CachedNetworkImage(
                    imageUrl: args.thumbnailUrl!,
                    height: 140.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 140.h,
                      color: AppColors.neutral100,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
                  ),
                ),
              if (args.thumbnailUrl != null &&
                  args.thumbnailUrl!.trim().isNotEmpty)
                SizedBox(height: AppSpacing.base.h),
              if (_ytController != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                  child: YoutubePlayer(
                    controller: _ytController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.purple,
                    progressColors: const ProgressBarColors(
                      playedColor: AppColors.purple,
                      handleColor: AppColors.pink600,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                )
              else
                _InvalidVideoCard(
                  onOpenExternal: _openInBrowser,
                ),
              SizedBox(height: AppSpacing.lg.h),
              _MetaCard(args: args),
            ],
          ),
        ),
      ],
    );
  }
}

class TherapyVideoSessionArgs {
  TherapyVideoSessionArgs({
    required this.sessionId,
    required this.therapyId,
    required this.sessionName,
    required this.instruction,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.watchStatus,
    this.duration,
  });

  final int sessionId;
  final int therapyId;
  final String sessionName;
  final String instruction;
  final String videoUrl;
  final String? thumbnailUrl;
  final int watchStatus;
  final String? duration;

  factory TherapyVideoSessionArgs.fromVideoItem(VideoItem v) {
    return TherapyVideoSessionArgs(
      sessionId: v.sessionId ?? 0,
      therapyId: v.therapyId ?? 0,
      sessionName: v.sessionName,
      instruction: v.instruction,
      videoUrl: v.videoUrl,
      thumbnailUrl: v.thumbnailUrl,
      watchStatus: v.watchStatus ?? 0,
      duration: v.duration,
    );
  }

  static TherapyVideoSessionArgs? fromGetArguments() {
    final raw = Get.arguments;
    if (raw == null) return null;
    if (raw is VideoItem) {
      return TherapyVideoSessionArgs.fromVideoItem(raw);
    }
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
    return TherapyVideoSessionArgs(
      sessionId: _asInt(m['session_id']),
      therapyId: _asInt(m['therapy_id']),
      sessionName: m['session_name']?.toString() ?? 'Video',
      instruction: m['instruction']?.toString() ?? '',
      videoUrl: m['video_url']?.toString() ?? '',
      thumbnailUrl: m['thumbnail_url']?.toString(),
      watchStatus: _asInt(m['watch_status']),
      duration: m['duration']?.toString(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.args});

  final TherapyVideoSessionArgs args;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            args.instruction.isEmpty ? '—' : args.instruction,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _chip('Session #${args.sessionId}'),
              _chip('Therapy #${args.therapyId}'),
              _chip('Watch status: ${args.watchStatus}'),
              if (args.duration != null && args.duration!.trim().isNotEmpty)
                _chip('Duration: ${args.duration}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, color: AppColors.purple700),
      ),
    );
  }
}

class _InvalidVideoCard extends StatelessWidget {
  const _InvalidVideoCard({required this.onOpenExternal});

  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.amber600.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40.sp, color: AppColors.amber600),
          SizedBox(height: 8.h),
          Text(
            'Could not load this video in the app. Open it in YouTube instead.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: onOpenExternal,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open link'),
          ),
        ],
      ),
    );
  }
}
