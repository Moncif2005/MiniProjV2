import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});
  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  int _step = 0;
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _priceCtrl  = TextEditingController();
  final _unitsCtrl  = TextEditingController();
  String? _category;

  // Step 2: units/videos
  // Preserved across back/forward navigation — only rebuilt when unit count actually changes
  int _currentUnit = 0;
  List<List<String>> _unitVideos = [];
  int _lastBuiltUnitCount = 0;
  final _videoUrlCtrl = TextEditingController();

  final _categories = ['Langues', 'Design', 'Coding', 'Business', 'Marketing'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _unitsCtrl.dispose();
    _videoUrlCtrl.dispose();
    super.dispose();
  }

  int get _unitCount => int.tryParse(_unitsCtrl.text) ?? 0;

  // ── Validation ──────────────────────────────────────────────────────────
  String? _validateStep0() {
    if (_nameCtrl.text.trim().isEmpty)
      return 'Le nom du cours est obligatoire.';
    if (_priceCtrl.text.trim().isEmpty)
      return 'Le prix est obligatoire.';
    if (double.tryParse(_priceCtrl.text.trim()) == null)
      return 'Le prix doit être un nombre valide.';
    if (_category == null)
      return 'Veuillez choisir une catégorie.';
    final count = _unitCount;
    if (count <= 0)
      return "Le nombre d'unités doit être supérieur à 0.";
    if (count > 50)
      return "Le nombre d'unités ne peut pas dépasser 50.";
    return null;
  }

  String? _validateStep1() {
    final emptyUnits = <int>[];
    for (int i = 0; i < _unitVideos.length; i++) {
      if (_unitVideos[i].isEmpty) emptyUnits.add(i + 1);
    }
    if (emptyUnits.isNotEmpty) {
      return 'Unité(s) sans vidéo : ${emptyUnits.join(', ')}. '
             'Ajoutez au moins une vidéo par unité.';
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _next() {
    if (_step == 0) {
      final error = _validateStep0();
      if (error != null) { _showError(error); return; }

      // Only rebuild unit list when the count actually changed — preserves videos
      final count = _unitCount;
      if (count != _lastBuiltUnitCount) {
        if (count > _lastBuiltUnitCount) {
          for (int i = _lastBuiltUnitCount; i < count; i++) _unitVideos.add([]);
        } else {
          _unitVideos = _unitVideos.sublist(0, count);
        }
        _lastBuiltUnitCount = count;
        _currentUnit = 0;
      }
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      final error = _validateStep1();
      if (error != null) { _showError(error); return; }
      setState(() => _step = 2);
      return;
    }

    // Step 2 → publish
    final newCourse = {
      'title':      _nameCtrl.text.trim(),
      'category':   _category!.toUpperCase(),
      'instructor': 'Vous',
      'rating':     '0.0',
      'duration':   '—',
      'lessons':    _unitVideos.fold(0, (sum, v) => sum + v.length),
      'students':   0,
      'status':     'active',
    };
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cours publié avec succès !'),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pushNamedAndRemoveUntil(
      context, '/enseignant/home', (r) => false,
      arguments: newCourse,
    );
  }

  void _prev() {
    if (_step > 0) {
      _videoUrlCtrl.clear();
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
      body: Column(children: [
        // ── AppBar ───────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
          decoration: BoxDecoration(
            color: c.bg,
            border: Border(bottom: BorderSide(color: c.border, width: 1.17)),
          ),
          child: Row(children: [
            GestureDetector(onTap: _prev, child: Container(
              width: 38, height: 38,
              decoration: ShapeDecoration(
                color: c.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.17, color: c.border),
                  borderRadius: BorderRadius.circular(14)),
                shadows: [BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.10),
                  blurRadius: 2, offset: const Offset(0, 1))]),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
            )),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Créer un Cours',
                style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              Text('Étape ${_step + 1} sur 3',
                style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
            ])),
          ]),
        ),

        // ── Scrollable content ───────────────────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildStepper(c),
            const SizedBox(height: 24),
            if (_step == 0) _step1(c),
            if (_step == 1) _step2(c),
            if (_step == 2) _step3(c),
          ]),
        )),

        // ── Bottom bar ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border, width: 1.17)),
          ),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(child: GestureDetector(onTap: _prev, child: Container(
                height: 56,
                decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text('Précédent',
                  style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
              ))),
              const SizedBox(width: 12),
            ],
            Expanded(child: GestureDetector(onTap: _next, child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.green.withOpacity(0.25)
                      : const Color(0xFFB9F8CF),
                  blurRadius: 15, offset: const Offset(0, 10), spreadRadius: -3)]),
              child: Center(child: Text(_nextLabel,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
            ))),
          ]),
        ),
      ]),
    );
  }

  // ── Stepper ──────────────────────────────────────────────────────────────
  Widget _buildStepper(ThemeColors c) => Row(
    children: List.generate(3, (i) {
      final isActive   = i == _step;
      final isComplete = i < _step;
      final isLast     = i == 2;
      return Expanded(child: Row(children: [
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
                ? Border.all(color: AppColors.green.withOpacity(0.3), width: 3)
                : null,
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.circle_outlined,
            color: (isComplete || isActive) ? Colors.white : c.textSecondary,
            size: isActive ? 20 : 16,
          ),
        ),
        if (!isLast) Expanded(child: Container(
          height: 4, margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isComplete ? AppColors.green : c.iconBg,
            borderRadius: BorderRadius.circular(100)),
        )),
      ]));
    }),
  );

  // ── STEP 1: Informations du cours ────────────────────────────────────────
  Widget _step1(ThemeColors c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Nom du cours *', c), const SizedBox(height: 8),
    _field(_nameCtrl, 'Ex: Maîtriser React et TypeScript', c),
    const SizedBox(height: 16),

    _label('Description du cours', c), const SizedBox(height: 8),
    _field(_descCtrl, 'Décrivez votre cours et ce que les étudiants vont apprendre...', c, maxLines: 4),
    const SizedBox(height: 16),

    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Prix (€) *', c), const SizedBox(height: 8),
        _field(_priceCtrl, 'Ex: 49.99', c, keyboardType: TextInputType.number),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Catégorie *', c), const SizedBox(height: 8),
        _dropdown(_category, 'Choisir', _categories, (v) => setState(() => _category = v), c),
      ])),
    ]),
    const SizedBox(height: 16),

    _label("Nombre d'unités (chapitres) *", c), const SizedBox(height: 8),
    _field(_unitsCtrl, 'Ex: 5', c,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {})),
    if (_unitsCtrl.text.isNotEmpty) ...[
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text('Vous allez créer $_unitCount unité(s) avec des vidéos dans chacune',
          style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
      ),
    ],
    const SizedBox(height: 16),

    _label('Image de couverture', c), const SizedBox(height: 8),
    Container(
      width: double.infinity, height: 120,
      decoration: ShapeDecoration(
        color: c.inputBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.17, color: c.border),
          borderRadius: BorderRadius.circular(14))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_upload_outlined, size: 32, color: c.textSecondary),
        const SizedBox(height: 8),
        Text('Cliquez pour sélectionner une image',
          style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('JPG, PNG (max 5MB)',
          style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
      ]),
    ),
  ]);

  // ── STEP 2: Unités / Vidéos ───────────────────────────────────────────────
  Widget _step2(ThemeColors c) {
    if (_unitVideos.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text("Aucune unité définie. Retournez à l'étape 1 et entrez le nombre d'unités.",
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontFamily: 'Inter', fontSize: 14)),
      ));
    }

    final totalUnits = _unitVideos.length;
    final videos = _unitVideos[_currentUnit];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Unit navigation header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Unité ${_currentUnit + 1} sur $totalUnits',
          style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        Row(children: [
          if (_currentUnit > 0)
            _iconBtn(Icons.chevron_left_rounded, c,
              () => setState(() { _videoUrlCtrl.clear(); _currentUnit--; })),
          const SizedBox(width: 8),
          if (_currentUnit < totalUnits - 1)
            _iconBtn(Icons.chevron_right_rounded, c,
              () => setState(() { _videoUrlCtrl.clear(); _currentUnit++; })),
        ]),
      ]),
      const SizedBox(height: 16),

      _label("Vidéos de l'unité *", c), const SizedBox(height: 8),

      // URL / Télécharger segmented control
      Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.iconBg,
          borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.10), blurRadius: 3, offset: const Offset(0, 1))]),
            child: Center(child: Text('URL Vidéo',
              style: TextStyle(color: AppColors.green, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
          )),
          Expanded(child: Center(child: Text('Télécharger',
            style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)))),
        ]),
      ),
      const SizedBox(height: 12),

      // URL input + add button
      Row(children: [
        Expanded(child: _field(_videoUrlCtrl, 'URL de la vidéo (YouTube, Vimeo, etc.)', c)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final url = _videoUrlCtrl.text.trim();
            if (url.isNotEmpty) {
              setState(() { _unitVideos[_currentUnit].add(url); _videoUrlCtrl.clear(); });
            }
          },
          child: Container(
            width: 52, height: 50,
            decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.add_rounded, color: Colors.white)),
        ),
      ]),
      const SizedBox(height: 8),

      Text('${videos.length} vidéo(s) ajoutée(s)',
        style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
      const SizedBox(height: 8),

      // Video list
      ...List.generate(videos.length, (i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.17, color: c.border),
            borderRadius: BorderRadius.circular(10))),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: c.iconBg,
              borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.play_circle_outline_rounded, color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Vidéo ${i + 1}',
                style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.iconBg,
                  borderRadius: BorderRadius.circular(4)),
                child: Text('URL',
                  style: TextStyle(color: AppColors.green, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 2),
            Text(videos[i], overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
          ])),
          GestureDetector(
            onTap: () => setState(() => _unitVideos[_currentUnit].removeAt(i)),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20)),
        ]),
      )),
    ]);
  }

  // ── STEP 3: Récapitulatif ─────────────────────────────────────────────────
  Widget _step3(ThemeColors c) {
    final totalVideos = _unitVideos.fold(0, (sum, v) => sum + v.length);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Green gradient summary card
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
            width: 1.17),
          borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Text('Récapitulatif du cours',
              style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),

          _summaryCard('Nom du cours', _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—', c),
          const SizedBox(height: 12),

          _summaryCard('Description', _descCtrl.text.isNotEmpty ? _descCtrl.text : '—', c),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: _summaryCard('Prix',
              _priceCtrl.text.isNotEmpty ? '${_priceCtrl.text} €' : 'Gratuit', c,
              valueColor: AppColors.green)),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard('Unités', '${_unitVideos.length}', c)),
          ]),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Vidéos', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
              const SizedBox(height: 4),
              if (totalVideos == 0)
                Text('Aucune vidéo ajoutée',
                  style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter'))
              else
                ...List.generate(_unitVideos.length, (i) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    Icon(Icons.play_circle_outline_rounded, size: 14, color: c.textSecondary),
                    const SizedBox(width: 6),
                    Text('Unité ${i + 1}: ${_unitVideos[i].length} vidéo(s)',
                      style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                  ]),
                )),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      // ✨ Prêt à publier? info banner
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
            width: 1.17),
          borderRadius: BorderRadius.circular(14)),
        child: Text.rich(TextSpan(children: [
          const TextSpan(text: '✨ Prêt à publier ? ',
            style: TextStyle(
              color: Color(0xFF1447E6), fontSize: 14,
              fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          TextSpan(
            text: 'Vérifiez les informations ci-dessus et appuyez sur "Publier le cours" pour mettre votre cours en ligne.',
            style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
        ])),
      ),
    ]);
  }

  // ── Reusable helpers ──────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, ThemeColors c, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: c.textPrimary, size: 20)));

  Widget _label(String text, ThemeColors c) => Text(text,
    style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700));

  Widget _field(
    TextEditingController ctrl, String hint, ThemeColors c, {
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) => Container(
    decoration: ShapeDecoration(
      color: c.inputBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.17, color: c.border),
        borderRadius: BorderRadius.circular(14))),
    child: TextField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: InputBorder.none)));

  Widget _dropdown(String? value, String hint, List<String> items,
      ValueChanged<String?> onChange, ThemeColors c) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: c.inputBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.17, color: c.border),
          borderRadius: BorderRadius.circular(14))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: value, isExpanded: true,
        dropdownColor: c.surface,
        hint: Text(hint, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
        items: items.map((e) => DropdownMenuItem(value: e,
          child: Text(e, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontSize: 14)))).toList(),
        onChanged: onChange,
      )));

  Widget _summaryCard(String label, String value, ThemeColors c, {Color? valueColor}) =>
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          color: valueColor ?? c.textPrimary, fontSize: 15,
          fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ]),
    );
}
