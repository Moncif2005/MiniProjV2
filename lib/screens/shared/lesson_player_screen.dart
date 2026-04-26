import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../theme/app_colors.dart';
import '../../services/progress_service.dart';
import '../../l10n/app_localizations.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final String courseId;
  final String lessonId;
  final String lessonType;
  final bool isLocked; // ✅ الجديد
  final String description; // ✅ الجديد

  const LessonPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonTitle,
    required this.courseId,
    required this.lessonId,
    this.lessonType = 'video',
    this.isLocked = false, // الافتراضي غير مقفل
    this.description = '',
  });
  
  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  YoutubePlayerController? _videoController;
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();

    if (widget.lessonType == 'video') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      _videoController = YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _markAsComplete() async {
    await _progressService.markLessonAsComplete(widget.courseId, widget.lessonId);
    // ✅ لا نستخدم setState هنا لأن StreamBuilder سيتحدث تلقائياً
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).lessonCompleted),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: isLandscape && widget.lessonType == 'video' 
          ? null 
          : AppBar(
              backgroundColor: c.surface,
              elevation: 0,
              title: Text(widget.lessonTitle, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary), onPressed: () => Navigator.pop(context)),
            ),
        body: Column(
          children: [
            if (widget.isLocked) ...[
              // ✅✅✅ عرض بديل للمحتوى المقفل ✅✅✅
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 9 / 16, // نفس ارتفاع الفيديو تقريباً
                color: Colors.grey.shade200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 48, color: Colors.grey.shade600),
                      const SizedBox(height: 12),
                      Text(
                        'This lesson is locked',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete the previous lesson to unlock',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (widget.lessonType == 'video') ...[
              // مشغل الفيديو العادي
               YoutubePlayerBuilder(
                onEnterFullScreen: () { SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]); },
                onExitFullScreen: () { SystemChrome.setPreferredOrientations(DeviceOrientation.values); },
                player: YoutubePlayer(controller: _videoController!, showVideoProgressIndicator: true, progressIndicatorColor: AppColors.primary),
                builder: (context, player) {
                  bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                  if (isLandscape) return Expanded(child: player);
                  return player;
                },
              ),
            ] else ...[
              // عارض الـ PDF العادي
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                color: Colors.grey[200],
                child: SfPdfViewer.network(widget.videoUrl, canShowScrollHead: false),
              ),
            ],

            // ── Lesson Info & Actions ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.lessonTitle, style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    
                    // ✅ عرض الوصف هنا
                    if (widget.description.isNotEmpty) ...[
                      Text(AppLocalizations.of(context).aboutThisLesson, style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.description, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.4)),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      widget.lessonType == 'video' ? 'Watch the full video to complete this lesson.' : 'Read the document carefully to complete this lesson.',
                      style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 32),

                    StreamBuilder<bool>(
                      stream: _progressService.isLessonCompletedStream(widget.courseId, widget.lessonId),
                      builder: (context, snap) {
                        final isDone = snap.data ?? false;
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            // ✅ إذا كان مقفلاً، الزر معطل دائماً
                            onPressed: widget.isLocked ? null : (isDone ? null : _markAsComplete),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isLocked ? Colors.grey : (isDone ? AppColors.green : AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: Icon(widget.isLocked ? Icons.lock : (isDone ? Icons.check_circle : Icons.play_circle_fill), color: Colors.white),
                            label: Text(
                              widget.isLocked ? 'Locked' : (isDone ? 'Completed' : 'Mark as Complete'),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                     // ... بقية الكود (ملاحظة المعلومات)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}