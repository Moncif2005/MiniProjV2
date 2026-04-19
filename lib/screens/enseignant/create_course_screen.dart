import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/courses_service.dart';
import '../../models/course_model.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});
  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  final _certificatePriceCtrl = TextEditingController(text: '10');
  final _unitsCtrl = TextEditingController();
  String? _category;

  // هيكلية جديدة للدروس: List of Units, where each Unit is a List of Lessons (Map)
  List<List<Map<String, String>>> _unitLessons = [];

  int _currentUnit = 0;
  int _lastBuiltUnitCount = 0;

  // تحكمات خاصة بإضافة درس جديد
  final _lessonTitleCtrl = TextEditingController();
  final _lessonUrlCtrl = TextEditingController();

  final _categories = ['Langues', 'Design', 'Coding', 'Business', 'Marketing'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _certificatePriceCtrl.dispose();
    _unitsCtrl.dispose();
    _lessonTitleCtrl.dispose();
    _lessonUrlCtrl.dispose();
    super.dispose();
  }

  int get _unitCount => int.tryParse(_unitsCtrl.text) ?? 0;

  // ── Validation ──────────────────────────────────────────────────────────
  String? _validateStep0() {
    if (_nameCtrl.text.trim().isEmpty)
      return 'Le nom du cours est obligatoire.';
    // السعر اختياري الآن (يمكن أن يكون 0)
    if (double.tryParse(_priceCtrl.text.trim()) == null)
      return 'Le prix doit être un nombre valide.';
    if (_category == null) return 'Veuillez choisir une catégorie.';

    final count = _unitCount;
    if (count <= 0) return "Le nombre d'unités doit être supérieur à 0.";
    if (count > 50) return "Le nombre d'unités ne peut pas dépasser 50.";
    return null;
  }

  String? _validateStep1() {
    final emptyUnits = <int>[];
    for (int i = 0; i < _unitLessons.length; i++) {
      if (_unitLessons[i].isEmpty) emptyUnits.add(i + 1);
    }
    if (emptyUnits.isNotEmpty) {
      return 'Unité(s) sans contenu : ${emptyUnits.join(', ')}. '
          'Ajoutez au moins une leçon par unité.';
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _next() async {
    if (_step == 0) {
      final error = _validateStep0();
      if (error != null) {
        _showError(error);
        return;
      }

      final count = _unitCount;
      if (count != _lastBuiltUnitCount) {
        if (count > _lastBuiltUnitCount) {
          for (int i = _lastBuiltUnitCount; i < count; i++)
            _unitLessons.add([]);
        } else {
          _unitLessons = _unitLessons.sublist(0, count);
        }
        _lastBuiltUnitCount = count;
        _currentUnit = 0;
      }
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      final error = _validateStep1();
      if (error != null) {
        _showError(error);
        return;
      }
      setState(() => _step = 2);
      return;
    }

    // Step 2 → Publish to Firestore ✅
    if (_step == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Vous devez être connecté pour publier un cours.');
        return;
      }

      // إظهار مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // حساب إجمالي الدروس
        int totalLessons = 0;
        for (var unit in _unitLessons) {
          totalLessons += unit.length;
        }

        final course = CourseModel(
          id: '', // Firestore will generate it
          title: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          instructorId: user.uid,
          instructorName: user.displayName ?? 'Enseignant',
          category: _category!,
          coursePrice: double.tryParse(_priceCtrl.text) ?? 0.0,
          certificatePrice: double.tryParse(_certificatePriceCtrl.text) ?? 0.0,
          imageUrl: null, // TODO: Add image upload later
          unitsCount: _unitLessons.length,
          totalLessons: totalLessons,
          createdAt: DateTime.now(),
          isPublished: true,
        );

        final courseId = await CoursesService().createCourse(course);

        if (courseId != null) {
          // ✅ حفظ الدروس كـ Subcollection
          await _saveLessonsToFirestore(courseId);

          Navigator.pop(context); // Hide loader

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cours publié avec succès !'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/enseignant/home',
            (r) => false,
          );
        } else {
          Navigator.pop(context);
          _showError('Échec de la publication.');
        }
      } catch (e) {
        Navigator.pop(context);
        _showError('Erreur: $e');
        debugPrint(e.toString());
      }
    }
  }

  // ✅ دالة مساعدة لحفظ الدروس في Subcollection
  Future<void> _saveLessonsToFirestore(String courseId) async {
    final db = FirebaseFirestore.instance;

    for (int unitIndex = 0; unitIndex < _unitLessons.length; unitIndex++) {
      final lessons = _unitLessons[unitIndex];
      for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
        final lessonData = lessons[lessonIndex];

        await db.collection('courses').doc(courseId).collection('lessons').add({
          'unitNumber': unitIndex + 1,
          'orderInUnit': lessonIndex + 1,
          'title': lessonData['title'],
          'videoUrl': lessonData['url'],
          'type': 'video', // Default type
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  void _prev() {
    if (_step > 0) {
      _lessonTitleCtrl.clear();
      _lessonUrlCtrl.clear();
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  String get _nextLabel {
    if (_step == 0) return 'Commencer les unités';
    if (_step == 1) return 'Voir le récapitulatif';
    return 'Publier le cours';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── AppBar ───────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.bg,
              border: Border(bottom: BorderSide(color: c.border, width: 1.17)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _prev,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: ShapeDecoration(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.17, color: c.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withOpacity(0.10),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créer un Cours',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Étape ${_step + 1} sur 3',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepper(c),
                  const SizedBox(height: 24),
                  if (_step == 0) _step1(c),
                  if (_step == 1) _step2(c),
                  if (_step == 2) _step3(c),
                ],
              ),
            ),
          ),

          // ── Bottom bar ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.border, width: 1.17)),
            ),
            child: Row(
              children: [
                if (_step > 0) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: _prev,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: c.iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Précédent',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: _next,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.green.withOpacity(0.25)
                                : const Color(0xFFB9F8CF),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _nextLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stepper ──────────────────────────────────────────────────────────────
  Widget _buildStepper(ThemeColors c) => Row(
    children: List.generate(3, (i) {
      final isActive = i == _step;
      final isComplete = i < _step;
      final isLast = i == 2;
      return Expanded(
        child: Row(
          children: [
            Container(
              width: isActive ? 40 : 32,
              height: isActive ? 40 : 32,
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.green
                    : isActive
                    ? AppColors.green
                    : c.iconBg,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(
                        color: AppColors.green.withOpacity(0.3),
                        width: 3,
                      )
                    : null,
              ),
              child: Icon(
                isComplete ? Icons.check_rounded : Icons.circle_outlined,
                color: (isComplete || isActive)
                    ? Colors.white
                    : c.textSecondary,
                size: isActive ? 20 : 16,
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isComplete ? AppColors.green : c.iconBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
          ],
        ),
      );
    }),
  );

  // ── STEP 1: Informations du cours ────────────────────────────────────────
  Widget _step1(ThemeColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Nom du cours *', c),
      const SizedBox(height: 8),
      _field(_nameCtrl, 'Ex: Maîtriser React et TypeScript', c),
      const SizedBox(height: 16),

      _label('Description du cours', c),
      const SizedBox(height: 8),
      _field(_descCtrl, 'Décrivez votre cours...', c, maxLines: 4),
      const SizedBox(height: 16),

      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Prix du cours (€)', c),
                const SizedBox(height: 8),
                _field(
                  _priceCtrl,
                  '0 (Gratuit)',
                  c,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Catégorie *', c),
                const SizedBox(height: 8),
                _dropdown(
                  _category,
                  'Choisir',
                  _categories,
                  (v) => setState(() => _category = v),
                  c,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Prix Certificat (€)', c),
                const SizedBox(height: 8),
                _field(
                  _certificatePriceCtrl,
                  '10',
                  c,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      _label("Nombre d'unités (chapitres) *", c),
      const SizedBox(height: 8),
      _field(
        _unitsCtrl,
        'Ex: 5',
        c,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
      if (_unitsCtrl.text.isNotEmpty) ...[
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Vous allez créer $_unitCount unité(s)',
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
      const SizedBox(height: 16),

      _label('Image de couverture', c),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        height: 120,
        decoration: ShapeDecoration(
          color: c.inputBg,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.17, color: c.border),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 32, color: c.textSecondary),
            const SizedBox(height: 8),
            Text(
              'Bientôt disponible',
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  // ── STEP 2: Unités / Vidéos ───────────────────────────────────────────────
  Widget _step2(ThemeColors c) {
    if (_unitLessons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "Aucune unité définie. Retournez à l'étape 1.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final totalUnits = _unitLessons.length;
    final lessons = _unitLessons[_currentUnit];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unit navigation header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unité ${_currentUnit + 1} sur $totalUnits',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                if (_currentUnit > 0)
                  _iconBtn(
                    Icons.chevron_left_rounded,
                    c,
                    () => setState(() {
                      _lessonTitleCtrl.clear();
                      _lessonUrlCtrl.clear();
                      _currentUnit--;
                    }),
                  ),
                const SizedBox(width: 8),
                if (_currentUnit < totalUnits - 1)
                  _iconBtn(
                    Icons.chevron_right_rounded,
                    c,
                    () => setState(() {
                      _lessonTitleCtrl.clear();
                      _lessonUrlCtrl.clear();
                      _currentUnit++;
                    }),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Title Input
        _label("Titre de la leçon", c),
        const SizedBox(height: 8),
        _field(_lessonTitleCtrl, 'Ex: Introduction', c),
        const SizedBox(height: 12),

        // URL Input
        _label("Lien YouTube / Vimeo", c),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _field(_lessonUrlCtrl, 'https://youtube.com/...', c),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final url = _lessonUrlCtrl.text.trim();
                final title = _lessonTitleCtrl.text.trim();

                if (url.isNotEmpty && title.isNotEmpty) {
                  setState(() {
                    _unitLessons[_currentUnit].add({
                      'title': title,
                      'url': url,
                    });
                    _lessonTitleCtrl.clear();
                    _lessonUrlCtrl.clear();
                  });
                } else {
                  _showError('Veuillez entrer un titre et un lien.');
                }
              },
              child: Container(
                width: 52,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          '${_unitLessons[_currentUnit].length} leçon(s) ajoutée(s)',
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),

        // Lessons list display
        ...List.generate(_unitLessons[_currentUnit].length, (i) {
          final lesson = _unitLessons[_currentUnit][i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: ShapeDecoration(
              color: c.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.17, color: c.border),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title']!,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lesson['url']!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _unitLessons[_currentUnit].removeAt(i)),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── STEP 3: Récapitulatif ─────────────────────────────────────────────────
  Widget _step3(ThemeColors c) {
    final totalVideos = _unitLessons.fold(0, (sum, v) => sum + v.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.green.withOpacity(0.10)
                : const Color(0xFFF0FDF4),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.green.withOpacity(0.30)
                  : const Color(0xFFB9F8CF),
              width: 1.17,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Récapitulatif du cours',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _summaryCard(
                'Nom du cours',
                _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
                c,
              ),
              const SizedBox(height: 12),
              _summaryCard(
                'Description',
                _descCtrl.text.isNotEmpty ? _descCtrl.text : '—',
                c,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Prix Cours',
                      '${_priceCtrl.text} €',
                      c,
                      valueColor: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      'Prix Certif',
                      '${_certificatePriceCtrl.text} €',
                      c,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenu',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_unitLessons.length} Unités • $totalVideos Leçons',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1447E6).withOpacity(0.12)
                : const Color(0xFFEFF6FF),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1447E6).withOpacity(0.35)
                  : const Color(0xFFBEDBFF),
              width: 1.17,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '✨ Prêt à publier ? ',
                  style: TextStyle(
                    color: Color(0xFF1447E6),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'Appuyez sur "Publier" pour mettre en ligne.',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable helpers ──────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, ThemeColors c, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: c.textPrimary, size: 20),
        ),
      );

  Widget _label(String text, ThemeColors c) => Text(
    text,
    style: TextStyle(
      color: c.textPrimary,
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    ThemeColors c, {
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) => Container(
    decoration: ShapeDecoration(
      color: c.inputBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.17, color: c.border),
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: c.textMuted,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: InputBorder.none,
      ),
    ),
  );

  Widget _dropdown(
    String? value,
    String hint,
    List<String> items,
    ValueChanged<String?> onChange,
    ThemeColors c,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: ShapeDecoration(
      color: c.inputBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.17, color: c.border),
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: c.surface,
        hint: Text(
          hint,
          style: TextStyle(
            color: c.textMuted,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChange,
      ),
    ),
  );

  Widget _summaryCard(
    String label,
    String value,
    ThemeColors c, {
    Color? valueColor,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: c.surface.withOpacity(0.6),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? c.textPrimary,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
