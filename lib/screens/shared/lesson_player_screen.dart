import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // ✅ استيراد مكتبة PDF
import '../../theme/app_colors.dart';
import '../../services/progress_service.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String videoUrl; // سيحتوي على رابط الفيديو أو رابط الـ PDF
  final String lessonTitle;
  final String courseId;
  final String lessonId;
  final String lessonType; // ✅ الجديد: 'video' or 'pdf'

  const LessonPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonTitle,
    required this.courseId,
    required this.lessonId,
    this.lessonType = 'video', // الافتراضي فيديو
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  YoutubePlayerController? _videoController;
  bool _isCompleted = false;
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();

    // السماح بالاتجاهين فقط إذا كان فيديو
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
      // إذا كان PDF، نثبت الوضع العمودي لتسهيل القراءة
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    // إعادة الوضع للعمودي عند الخروج
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _markAsComplete() async {
    await _progressService.markLessonAsComplete(
      widget.courseId,
      widget.lessonId,
    );
    setState(() => _isCompleted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lesson completed! 🎉'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          title: Text(
            widget.lessonTitle,
            style: TextStyle(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // ── Dynamic Content Area (Video or PDF) ──
            if (widget.lessonType == 'video') ...[
              // ✅ مشغل الفيديو
              YoutubePlayerBuilder(
                onExitFullScreen: () {
                  SystemChrome.setPreferredOrientations(
                    DeviceOrientation.values,
                  );
                },
                player: YoutubePlayer(
                  controller: _videoController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppColors.primary,
                ),
                builder: (context, player) => player,
              ),
            ] else ...[
              // ✅ عارض الـ PDF
              Container(
                height:
                    MediaQuery.of(context).size.height * 0.5, // يأخذ نصف الشاشة
                color: Colors.grey[200],
                child: SfPdfViewer.network(
                  widget.videoUrl, // الرابط هنا هو رابط الـ PDF
                  canShowScrollHead: false,
                ),
              ),
            ],

            // ── Lesson Info & Actions ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lessonTitle,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.lessonType == 'video'
                          ? 'Watch the full video to complete this lesson.'
                          : 'Read the document carefully to complete this lesson.',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 32),

                    StreamBuilder<bool>(
                      stream: _progressService.isLessonCompletedStream(
                        widget.courseId,
                        widget.lessonId,
                      ),
                      builder: (context, snap) {
                        final isDone = snap.data ?? false;
                        if (isDone && !_isCompleted)
                          setState(() => _isCompleted = true);

                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isDone ? null : _markAsComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDone
                                  ? AppColors.green
                                  : AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              isDone
                                  ? Icons.check_circle
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                            ),
                            label: Text(
                              isDone ? 'Completed' : 'Mark as Complete',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: c.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your progress is saved automatically when you mark a lesson as complete.',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
