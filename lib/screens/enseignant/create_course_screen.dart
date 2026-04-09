import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});
  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  int _step = 0;
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _durCtrl   = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _category, _level, _language;
  final List<Map<String,String>> _lessons = [];

  final _categories = ['Langues','Design','Coding','Business','Marketing'];
  final _levels     = ['Débutant','Intermédiaire','Avancé'];
  final _languages  = ['Français','Arabe','Anglais','Espagnol'];

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _durCtrl.dispose();   _priceCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) { setState(() => _step++); return; }
    final newCourse = {
      'title':      _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'Sans titre',
      'category':   (_category ?? 'GENERAL').toUpperCase(),
      'instructor': 'Vous',
      'rating':     '0.0',
      'duration':   _durCtrl.text.isNotEmpty ? _durCtrl.text : '—',
      'lessons':    _lessons.length,
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
    if (_step > 0) { setState(() => _step--); } else { Navigator.pop(context); }
  }

  void _addLesson() {
    final t = TextEditingController(), d = TextEditingController();
    final c = context.colors;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: c.surface,
      title: Text('Ajouter une leçon',
          style: TextStyle(color: c.textPrimary, fontFamily:'Inter', fontWeight:FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: t, style: TextStyle(color: c.textPrimary),
          decoration: InputDecoration(hintText:'Titre de la leçon',
            hintStyle: TextStyle(color: c.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height:12),
        TextField(controller: d, style: TextStyle(color: c.textPrimary),
          decoration: InputDecoration(hintText:'Durée (ex: 15 min)',
            hintStyle: TextStyle(color: c.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: c.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
          onPressed: () {
            if (t.text.isNotEmpty) { setState(() => _lessons.add({'title':t.text,'duration':d.text})); }
            Navigator.pop(context);
          },
          child: const Text('Ajouter', style: TextStyle(color:Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24,48,24,16),
          decoration: BoxDecoration(
            color: c.bg,
            border: Border(bottom: BorderSide(color: c.border, width:1.24)),
          ),
          child: Row(children: [
            GestureDetector(onTap: _prev, child: Container(
              width:38, height:38,
              decoration: ShapeDecoration(color: c.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width:1.24, color: c.border),
                  borderRadius: BorderRadius.circular(14)),
                shadows: const [BoxShadow(color: Color(0x19000000), blurRadius:2, offset: Offset(0,1))]),
              child: Icon(Icons.arrow_back_ios_new_rounded, size:16, color: c.textPrimary),
            )),
            const SizedBox(width:16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Créer un Cours', style: TextStyle(color: c.textPrimary, fontSize:20, fontFamily:'Inter', fontWeight:FontWeight.w700)),
              Text('Étape \${_step+1} sur 3', style: TextStyle(color: c.textSecondary, fontSize:14, fontFamily:'Inter')),
            ]),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: List.generate(3, (i) {
              final done = i <= _step; final isLast = i==2;
              return Expanded(child: Row(children: [
                Container(
                  width: i==_step?40:32, height: i==_step?40:32,
                  decoration: BoxDecoration(color: done ? AppColors.green : c.iconBg, shape: BoxShape.circle),
                  child: Icon(done ? Icons.check_rounded : Icons.circle_outlined,
                    color: done ? Colors.white : c.textSecondary, size: i==_step?20:16),
                ),
                if (!isLast) Expanded(child: Container(
                  height:4, margin: const EdgeInsets.symmetric(horizontal:4),
                  decoration: BoxDecoration(color: i<_step ? AppColors.green : c.iconBg,
                    borderRadius: BorderRadius.circular(100)),
                )),
              ]));
            })),
            const SizedBox(height:24),
            if (_step==0) _step1(c),
            if (_step==1) _step2(c),
            if (_step==2) _step3(c),
          ]),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(24,16,24,32),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border, width:1.24)),
          ),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(child: GestureDetector(onTap: _prev, child: Container(
                height:56,
                decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text('Précédent', style: TextStyle(color: c.textPrimary, fontSize:16, fontFamily:'Inter', fontWeight:FontWeight.w700))),
              ))),
              const SizedBox(width:12),
            ],
            Expanded(child: GestureDetector(onTap: _next, child: Container(
              height:56,
              decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0xFFB9F8CF), blurRadius:15, offset: Offset(0,10), spreadRadius:-3)]),
              child: Center(child: Row(mainAxisSize:MainAxisSize.min, children: [
                Text(_step==2 ? 'Publier' : 'Suivant', style: const TextStyle(color:Colors.white, fontSize:16, fontFamily:'Inter', fontWeight:FontWeight.w700)),
                const SizedBox(width:8),
                Icon(_step==2 ? Icons.publish_rounded : Icons.arrow_forward_rounded, color:Colors.white, size:20),
              ])),
            ))),
          ]),
        ),
      ]),
    );
  }

  Widget _step1(ThemeColors c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Titre du cours *', c), const SizedBox(height:8),
    _field(_titleCtrl, 'Ex: Maîtriser le JavaScript moderne', c),
    const SizedBox(height:16),
    _label('Description', c), const SizedBox(height:8),
    _field(_descCtrl, 'Décrivez votre cours...', c, maxLines:4),
    const SizedBox(height:16),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Catégorie *', c), const SizedBox(height:8),
        _dropdown(_category, 'Choisir', _categories, (v)=>setState(()=>_category=v), c),
      ])),
      const SizedBox(width:16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Niveau', c), const SizedBox(height:8),
        _dropdown(_level, 'Choisir', _levels, (v)=>setState(()=>_level=v), c),
      ])),
    ]),
    const SizedBox(height:16),
    _label('Image de couverture', c), const SizedBox(height:8),
    Container(
      width: double.infinity, height:160,
      decoration: ShapeDecoration(shape: RoundedRectangleBorder(
        side: BorderSide(width:1.24, color: c.border),
        borderRadius: BorderRadius.circular(14))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_upload_outlined, size:32, color: c.textSecondary),
        const SizedBox(height:8),
        Text('Cliquez pour télécharger', style: TextStyle(color: c.textSecondary, fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w500)),
      ]),
    ),
  ]);

  Widget _step2(ThemeColors c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Leçons du cours', style: TextStyle(color: c.textPrimary, fontSize:18, fontFamily:'Inter', fontWeight:FontWeight.w700)),
      GestureDetector(onTap: _addLesson, child: Container(
        padding: const EdgeInsets.symmetric(horizontal:16, vertical:8),
        decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14)),
        child: const Row(children: [
          Icon(Icons.add_rounded, color:Colors.white, size:16),
          SizedBox(width:6),
          Text('Ajouter', style: TextStyle(color:Colors.white, fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700)),
        ]),
      )),
    ]),
    const SizedBox(height:16),
    if (_lessons.isEmpty)
      Container(
        width: double.infinity, height:200,
        decoration: ShapeDecoration(color: c.surface, shape: RoundedRectangleBorder(
          side: BorderSide(width:1.24, color: c.border),
          borderRadius: BorderRadius.circular(16))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.menu_book_outlined, size:48, color: c.textSecondary),
          const SizedBox(height:12),
          Text('Aucune leçon ajoutée', style: TextStyle(color: c.textSecondary, fontSize:16, fontFamily:'Inter')),
          const SizedBox(height:4),
          Padding(padding: const EdgeInsets.symmetric(horizontal:24),
            child: Text('Commencez par ajouter des leçons à votre cours', textAlign:TextAlign.center,
              style: TextStyle(color: c.textMuted, fontSize:14, fontFamily:'Inter'))),
        ]),
      )
    else
      ...List.generate(_lessons.length, (i) => Container(
        margin: const EdgeInsets.only(bottom:12),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(color: c.surface, shape: RoundedRectangleBorder(
          side: BorderSide(width:1.24, color: c.border),
          borderRadius: BorderRadius.circular(14))),
        child: Row(children: [
          Container(width:36, height:36,
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('\${i+1}', style: const TextStyle(color:AppColors.green, fontFamily:'Inter', fontWeight:FontWeight.w700)))),
          const SizedBox(width:12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_lessons[i]['title']!, style: TextStyle(color: c.textPrimary, fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700)),
            Text(_lessons[i]['duration']!, style: TextStyle(color: c.textSecondary, fontSize:12, fontFamily:'Inter')),
          ])),
          GestureDetector(onTap: ()=>setState(()=>_lessons.removeAt(i)),
            child: const Icon(Icons.delete_outline_rounded, color:AppColors.red, size:20)),
        ]),
      )),
  ]);

  Widget _step3(ThemeColors c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label("Langue d'enseignement", c), const SizedBox(height:8),
    _dropdown(_language, 'Choisir une langue', _languages, (v)=>setState(()=>_language=v), c),
    const SizedBox(height:16),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Durée totale', c), const SizedBox(height:8),
        _field(_durCtrl, 'Ex: 4 heures', c),
      ])),
      const SizedBox(width:16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Prix (€)', c), const SizedBox(height:8),
        _field(_priceCtrl, 'Ex: 49.99', c, keyboardType: TextInputType.number),
      ])),
    ]),
    const SizedBox(height:24),
    Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.green.withOpacity(0.12) : AppColors.greenLight,
        border: Border.all(color: const Color(0xFFB9F8CF), width:1.24),
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width:40, height:40, decoration: const BoxDecoration(color:AppColors.green, shape:BoxShape.circle),
            child: const Icon(Icons.check_rounded, color:Colors.white, size:20)),
          const SizedBox(width:12),
          Text('Récapitulatif', style: TextStyle(color: c.textPrimary, fontSize:18, fontFamily:'Inter', fontWeight:FontWeight.w700)),
        ]),
        const SizedBox(height:16),
        _summaryRow('Titre:', _titleCtrl.text.isNotEmpty ? _titleCtrl.text : '—', c),
        const SizedBox(height:8),
        _summaryRow('Catégorie:', _category ?? '—', c),
        const SizedBox(height:8),
        _summaryRow('Leçons:', '\${_lessons.length} leçon(s)', c),
        const SizedBox(height:8),
        _summaryRow('Prix:', _priceCtrl.text.isNotEmpty ? '\${_priceCtrl.text} €' : 'Gratuit', c, valueColor: AppColors.green),
      ]),
    ),
  ]);

  Widget _label(String text, ThemeColors c) => Text(text,
    style: TextStyle(color: c.textPrimary, fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700));

  Widget _field(TextEditingController ctrl, String hint, ThemeColors c, {int maxLines=1, TextInputType? keyboardType}) =>
    Container(
      decoration: ShapeDecoration(color: c.inputBg, shape: RoundedRectangleBorder(
        side: BorderSide(width:1.24, color: c.border),
        borderRadius: BorderRadius.circular(14))),
      child: TextField(controller: ctrl, maxLines:maxLines, keyboardType:keyboardType,
        style: TextStyle(color: c.textPrimary),
        decoration: InputDecoration(hintText:hint,
          hintStyle: TextStyle(color: c.textMuted, fontSize:16, fontFamily:'Inter'),
          contentPadding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
          border: InputBorder.none)));

  Widget _dropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChange, ThemeColors c) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal:12),
      decoration: ShapeDecoration(color: c.inputBg, shape: RoundedRectangleBorder(
        side: BorderSide(width:1.24, color: c.border),
        borderRadius: BorderRadius.circular(14))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: value, isExpanded: true,
        dropdownColor: c.surface,
        hint: Text(hint, style: TextStyle(color: c.textMuted, fontSize:14, fontFamily:'Inter')),
        items: items.map((e) => DropdownMenuItem(value:e,
          child: Text(e, style: TextStyle(color: c.textPrimary, fontFamily:'Inter', fontSize:14)))).toList(),
        onChanged: onChange,
      )));

  Widget _summaryRow(String label, String value, ThemeColors c, {Color? valueColor}) =>
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: c.textSecondary, fontSize:14, fontFamily:'Inter')),
      Text(value, style: TextStyle(color: valueColor ?? c.textPrimary, fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700)),
    ]);
}
