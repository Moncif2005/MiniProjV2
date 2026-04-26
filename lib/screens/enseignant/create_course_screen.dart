import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_picker/file_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';

import '../../services/courses_service.dart';

import '../../models/course_model.dart';

import '../../services/cloudinary_service.dart';
import '../../l10n/app_localizations.dart';

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

  List<List<Map<String, String>>> _unitLessons = [];
  int _currentUnit = 0;
  int _lastBuiltUnitCount = 0;

  final _lessonTitleCtrl = TextEditingController();
  final _lessonUrlCtrl = TextEditingController();
  final _lessonDescCtrl = TextEditingController(); // ✅ متحكم وصف الدرس الجديد

  File? _coverImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  String _currentLessonType = 'video';
  File? _selectedPdfFile;
  bool _isUploadingPdf = false;
  String? _uploadedPdfUrl;

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
    _lessonDescCtrl.dispose(); // ✅ التخلص من المتحكم الجديد
    super.dispose();
  }

  int get _unitCount => int.tryParse(_unitsCtrl.text) ?? 0;

  Future<void> _pickAndUploadPdf() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdfFile = File(result.files.single.path!);
        _isUploadingPdf = true;
        _uploadedPdfUrl = null;
      });

      try {
        final url = await CloudinaryService.upload(
          file: _selectedPdfFile!,
          folder: 'course_pdfs',
          resourceType: 'raw',
        );

        if (url != null) {
          setState(() {
            _uploadedPdfUrl = url;
            _isUploadingPdf = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).pdfUploaded),
                backgroundColor: AppColors.green,
              ),
            );
          }
        } else {
          setState(() => _isUploadingPdf = false);
          _showError('Failed to upload PDF.');
        }
      } catch (e) {
        setState(() => _isUploadingPdf = false);
        _showError('Error: $e');
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _coverImage = File(image.path);
      _isUploadingImage = true;
      _uploadedImageUrl = null;
    });

    try {
      final url = await CloudinaryService.upload(
        file: _coverImage!,
        folder: 'course_covers',
        resourceType: 'image',
      ).timeout(const Duration(seconds: 60));

      if (url != null && url.isNotEmpty) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploadingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).imageUploaded),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } else {
        throw Exception('Cloudinary returned null URL.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        _showError('Upload failed: $e');
      }
    }
  }

  String? _validateStep0() {
    if (_nameCtrl.text.trim().isEmpty)
      return 'Le nom du cours est obligatoire.';
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
      return 'Unité(s) sans contenu : ${emptyUnits.join(', ')}. Ajoutez au moins une leçon par unité.';
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

    if (_step == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Vous devez être connecté.');
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        int totalLessons = 0;
        for (var unit in _unitLessons) {
          totalLessons += unit.length;
        }

        final course = CourseModel(
          id: '',
          title: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          instructorId: user.uid,
          instructorName: user.displayName ?? 'Enseignant',
          category: _category!,
          coursePrice: double.tryParse(_priceCtrl.text) ?? 0.0,
          certificatePrice: double.tryParse(_certificatePriceCtrl.text) ?? 0.0,
          imageUrl: _uploadedImageUrl,
          unitsCount: _unitLessons.length,
          totalLessons: totalLessons,
          createdAt: DateTime.now(),
          isPublished: false, // ✅ لا ننشره فوراً
          status: 'pending',  // ✅ نضعه قيد المراجعة
        );
        final courseId = await CoursesService().createCourse(course);
        if (courseId != null) {
          await _saveLessonsToFirestore(courseId);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).coursePublished),
              backgroundColor: AppColors.green,
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
      }
    }
  }

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
          'type': lessonData['type'] ?? 'video',
          'description': lessonData['description'] ?? '', // ✅ حفظ الوصف
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  void _prev() {
    if (_step > 0) {
      _lessonTitleCtrl.clear();
      _lessonUrlCtrl.clear();
      _lessonDescCtrl.clear(); // ✅ مسح الوصف عند العودة
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

  Widget _step1(ThemeColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Nom du cours *', c),
      const SizedBox(height: 8),
      _field(_nameCtrl, 'Ex: Maîtriser React', c),
      const SizedBox(height: 16),
      _label(AppLocalizations.of(context).description, c),
      const SizedBox(height: 8),
      _field(_descCtrl, 'Décrivez...', c, maxLines: 4),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Prix (€)', c),
                const SizedBox(height: 8),
                _field(_priceCtrl, '0', c, keyboardType: TextInputType.number),
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
      _label("Nombre d'unités *", c),
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
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
        ),
      ],
      const SizedBox(height: 16),
      _label('Image de couverture', c),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _isUploadingImage ? null : _pickAndUploadImage,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: ShapeDecoration(
            color: c.inputBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.17, color: c.border),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isUploadingImage
              ? const Center(child: CircularProgressIndicator())
              : _uploadedImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                )
              : _coverImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(_coverImage!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: c.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez pour sélectionner',
                      style: TextStyle(color: c.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );

  Widget _step2(ThemeColors c) {
    if (_unitLessons.isEmpty)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "Aucune unité définie.",
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary),
          ),
        ),
      );

    final totalUnits = _unitLessons.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unité ${_currentUnit + 1} sur $totalUnits',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
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
                      _lessonDescCtrl.clear(); // ✅ مسح الوصف عند تغيير الوحدة
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
                      _lessonDescCtrl.clear(); // ✅ مسح الوصف عند تغيير الوحدة
                      _currentUnit++;
                    }),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalizations.of(context).video),
                value: 'video',
                groupValue: _currentLessonType,
                onChanged: (val) {
                  setState(() {
                    _currentLessonType = val!;
                    _uploadedPdfUrl = null;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalizations.of(context).pdf),
                value: 'pdf',
                groupValue: _currentLessonType,
                onChanged: (val) {
                  setState(() {
                    _currentLessonType = val!;
                    _lessonUrlCtrl.clear();
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _label("Titre", c),
        const SizedBox(height: 8),
        _field(_lessonTitleCtrl, 'Titre...', c),
        
        // ✅ إضافة حقل وصف الدرس
        const SizedBox(height: 12),
        _label("Description (Optionnel)", c),
        const SizedBox(height: 8),
        _field(_lessonDescCtrl, 'Brief description of this lesson...', c, maxLines: 2),

        const SizedBox(height: 16),

        if (_currentLessonType == 'video') ...[
          _label("Lien YouTube", c),
          const SizedBox(height: 8),
          _field(_lessonUrlCtrl, 'https://...', c),
        ] else ...[
          _label("Fichier PDF", c),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isUploadingPdf ? null : _pickAndUploadPdf,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: ShapeDecoration(
                color: c.inputBg,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.17, color: c.border),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isUploadingPdf
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _uploadedPdfUrl != null
                              ? 'PDF Prêt ✅'
                              : 'Uploader PDF',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
        const SizedBox(height: 16),

        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                final title = _lessonTitleCtrl.text.trim();
                final desc = _lessonDescCtrl.text.trim(); // ✅ جلب الوصف
                
                if (_currentLessonType == 'video') {
                  final url = _lessonUrlCtrl.text.trim();
                  if (url.isNotEmpty && title.isNotEmpty) {
                    setState(() {
                      _unitLessons[_currentUnit].add({
                        'title': title,
                        'url': url,
                        'type': 'video',
                        'description': desc, // ✅ حفظ الوصف
                      });
                      _lessonTitleCtrl.clear();
                      _lessonUrlCtrl.clear();
                      _lessonDescCtrl.clear(); // ✅ مسح الحقول بعد الإضافة
                    });
                  } else {
                    _showError('Titre et URL requis');
                  }
                } else {
                  if (_uploadedPdfUrl != null && title.isNotEmpty) {
                    setState(() {
                      _unitLessons[_currentUnit].add({
                        'title': title,
                        'url': _uploadedPdfUrl!,
                        'type': 'pdf',
                        'description': desc, // ✅ حفظ الوصف
                      });
                      _lessonTitleCtrl.clear();
                      _lessonDescCtrl.clear(); // ✅ مسح الحقول بعد الإضافة
                      _uploadedPdfUrl = null;
                    });
                  } else {
                    _showError('Titre et PDF requis');
                  }
                }
              },
              child: Container(
                width: 52,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...List.generate(_unitLessons[_currentUnit].length, (i) {
          final lesson = _unitLessons[_currentUnit][i];
          final isPdf = lesson['type'] == 'pdf';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              color: c.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: c.border),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.play_circle,
                  color: isPdf ? Colors.red : AppColors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (lesson['description']?.isNotEmpty ?? false)
                        Text(
                          lesson['description']!,
                          style: TextStyle(fontSize: 12, color: c.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      setState(() => _unitLessons[_currentUnit].removeAt(i)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _step3(ThemeColors c) {
    final total = _unitLessons.fold(0, (sum, v) => sum + v.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.green),
          ),
          child: Column(
            children: [
              Text(
                'Récapitulatif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${_unitLessons.length} Unités • $total Leçons',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Prêt à publier !',
            style: TextStyle(color: c.textSecondary),
          ),
        ),
      ],
    );
  }

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
          child: Icon(icon, size: 20),
        ),
      );
  Widget _label(String text, ThemeColors c) =>
      Text(text, style: TextStyle(fontWeight: FontWeight.bold));
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
        side: BorderSide(color: c.border),
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
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
        side: BorderSide(color: c.border),
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChange,
      ),
    ),
  );
}