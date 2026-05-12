class VideoItem {
  const VideoItem({
    required this.sessionName,
    required this.videoUrl,
    this.sessionId,
    this.therapyId,
    this.instruction = '',
    this.thumbnailUrl,
    this.watchStatus,
    this.duration,
  });

  final int? sessionId;
  final int? therapyId;
  final String sessionName;
  final String instruction;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? watchStatus;
  final String? duration;

  /// Map for [VideoPlayerScreen] via `Get.toNamed(AppRoutes.videoPlayerScreen, arguments: ...)`.
  Map<String, dynamic> toPlayerArguments() => {
        'session_id': sessionId ?? 0,
        'therapy_id': therapyId ?? 0,
        'session_name': sessionName,
        'instruction': instruction,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'watch_status': watchStatus ?? 0,
        'duration': duration,
      };
}

