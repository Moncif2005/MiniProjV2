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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cours publié avec succès !'),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pushNamedAndRemoveUntil(context, '/enseignant/home', (r)=>false);
  }

  void _prev() {
    if (_step > 0) { setState(() => _step--); } else { Navigator.pop(context); }
  }

  void _addLesson() {
    final t = TextEditingController(), d = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Ajouter une leçon', style: TextStyle(fontFamily:'Inter',fontWeight:FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: t, decoration: const InputDecoration(hintText:'Titre de la leçon', border: OutlineInputBorder())),
        const SizedBox(height:12),
        TextField(controller: d, decoration: const InputDecoration(hintText:'Durée (ex: 15 min)', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(children: [
        // AppBar
        Container(
          padding: const EdgeInsets.fromLTRB(24,48,24,16),
          decoration: const BoxDecoration(color: Color(0xFFFAFAFA),
            border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width:1.24))),
          child: Row(children: [
            GestureDetector(onTap: _prev, child: Container(
              width:38, height:38,
              decoration: ShapeDecoration(color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width:1.24, color: Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(14)),
                shadows: const [BoxShadow(color: Color(0x19000000), blurRadius:2, offset: Offset(0,1))]),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size:16, color: Color(0xFF171717)),
            )),
            const SizedBox(width:16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Créer un Cours', style: TextStyle(color: Color(0xFF171717), fontSize:20, fontFamily:'Inter', fontWeight:FontWeight.w700)),
              Text('Étape ${_step+1} sur 3', style: const TextStyle(color: Color(0xFF737373), fontSize:14, fontFamily:'Inter')),
            ]),
          ]),
        ),

        // Body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stepper
            Row(children: List.generate(3, (i) {
              final done = i <= _step; final isLast = i==2;
              return Expanded(child: Row(children: [
                Container(
                  width: i==_step?40:32, height: i==_step?40:32,
                  decoration: BoxDecoration(color: done ? AppColors.green : const Color(0xFFE5E5E5), shape: BoxShape.circle),
                  child: Icon(done ? Icons.check_rounded : Icons.circle_outlined,
                    color: done ? Colors.white : const Color(0xFF737373), size: i==_step?20:16),
                ),
                if (!isLast) Expanded(child: Container(
                  height:4, margin: const EdgeInsets.symmetric(horizontal:4),
                  decoration: BoxDecoration(color: i<_step ? AppColors.green : const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(100)),
                )),
              ]));
            })),
            const SizedBox(height:24),

            if (_step==0) _step1(),
            if (_step==1) _step2(),
            if (_step==2) _step3(),
          ]),
        )),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.fromLTRB(24,16,24,32),
          decoration: const BoxDecoration(color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width:1.24))),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(child: GestureDetector(onTap: _prev, child: Container(
                height:56,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('Précédent', style: TextStyle(color: Color(0xFF404040), fontSize:16, fontFamily:'Inter', fontWeight:FontWeight.w700))),
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

  Widget _step1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Titre du cours *'), const SizedBox(height:8),
    _field(_titleCtrl, 'Ex: Maîtriser le JavaScript moderne'),
    const SizedBox(height:16),
    _label('Description'), const SizedBox(height:8),
    _field(_descCtrl, 'Décrivez votre cours et ce que les étudiants vont apprendre...', maxLines:4),
    const SizedBox(height:16),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Catégorie *'), const SizedBox(height:8),
        _dropdown(_category, 'Choisir', _categories, (v)=>setState(()=>_category=v)),
      ])),
      const SizedBox(width:16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Niveau'), const SizedBox(height:8),
        _dropdown(_level, 'Choisir', _levels, (v)=>setState(()=>_level=v)),
      ])),
    ]),
    const SizedBox(height:16),
    _label('Image de couverture'), const SizedBox(height:8),
    Container(
      width: double.infinity, height:160,
      decoration: ShapeDecoration(shape: RoundedRectangleBorder(
        side: const BorderSide(width:1.24, color: Color(0xFFD4D4D4)),
        borderRadius: BorderRadius.circular(14))),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_upload_outlined, size:32, color: Color(0xFF737373)),
        SizedBox(height:8),
        Text('Cliquez pour télécharger', style: TextStyle(color: Color(0xFF737373), fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w500)),
      ]),
    ),
  ]);

  Widget _step2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Leçons du cours', style: TextStyle(color: Color(0xFF171717), fontSize:18, fontFamily:'Inter', fontWeight:FontWeight.w700)),
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
        decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(
          side: const BorderSide(width:1.24, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(16))),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.menu_book_outlined, size:48, color: Color(0xFF737373)),
          SizedBox(height:12),
          Text('Aucune leçon ajoutée', style: TextStyle(color: Color(0xFF737373), fontSize:16, fontFamily:'Inter')),
          SizedBox(height:4),
          Padding(padding: EdgeInsets.symmetric(horizontal:24),
            child: Text('Commencez par ajouter des leçons à votre cours', textAlign:TextAlign.center,
              style: TextStyle(color: Color(0xFFA1A1A1), fontSize:14, fontFamily:'Inter'))),
        ]),
      )
    else
      ...List.generate(_lessons.length, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom:12),
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(
            side: const BorderSide(width:1.24, color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(14))),
          child: Row(children: [
            Container(width:36, height:36,
              decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('${i+1}', style: const TextStyle(color:AppColors.green, fontFamily:'Inter', fontWeight:FontWeight.w700)))),
            const SizedBox(width:12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_lessons[i]['title']!, style: const TextStyle(color: Color(0xFF171717), fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700)),
              Text(_lessons[i]['duration']!, style: const TextStyle(color: Color(0xFF737373), fontSize:12, fontFamily:'Inter')),
            ])),
            GestureDetector(onTap: ()=>setState(()=>_lessons.removeAt(i)),
              child: const Icon(Icons.delete_outline_rounded, color:AppColors.red, size:20)),
          ]),
        );
      }),
  ]);

  Widget _step3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label("Langue d'enseignement"), const SizedBox(height:8),
    _dropdown(_language, 'Choisir une langue', _languages, (v)=>setState(()=>_language=v)),
    const SizedBox(height:16),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Durée totale'), const SizedBox(height:8),
        _field(_durCtrl, 'Ex: 4 heures'),
      ])),
      const SizedBox(width:16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Prix (€)'), const SizedBox(height:8),
        _field(_priceCtrl, 'Ex: 49.99', keyboardType: TextInputType.number),
      ])),
    ]),
    const SizedBox(height:24),
    Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)]),
        border: Border.all(color: const Color(0xFFB9F8CF), width:1.24),
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width:40, height:40, decoration: const BoxDecoration(color:AppColors.green, shape:BoxShape.circle),
            child: const Icon(Icons.check_rounded, color:Colors.white, size:20)),
          const SizedBox(width:12),
          const Text('Récapitulatif', style: TextStyle(color: Color(0xFF171717), fontSize:18, fontFamily:'Inter', fontWeight:FontWeight.w700)),
        ]),
        const SizedBox(height:16),
        _summaryRow('Titre:', _titleCtrl.text.isNotEmpty ? _titleCtrl.text : '—'),
        const SizedBox(height:8),
        _summaryRow('Catégorie:', _category ?? '—'),
        const SizedBox(height:8),
        _summaryRow('Leçons:', '${_lessons.length} leçon(s)'),
        const SizedBox(height:8),
        _summaryRow('Prix:', _priceCtrl.text.isNotEmpty ? '${_priceCtrl.text} €' : 'Gratuit', valueColor: AppColors.green),
      ]),
    ),
  ]);

  Widget _label(String text) => Text(text, style: const TextStyle(color: Color(0xFF404040), fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700));

  Widget _field(TextEditingController ctrl, String hint, {int maxLines=1, TextInputType? keyboardType}) =>
    Container(
      decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(
        side: const BorderSide(width:1.24, color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(14))),
      child: TextField(controller: ctrl, maxLines:maxLines, keyboardType:keyboardType,
        decoration: InputDecoration(hintText:hint,
          hintStyle: const TextStyle(color: Color(0x7F0A0A0A), fontSize:16, fontFamily:'Inter'),
          contentPadding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
          border: InputBorder.none)));

  Widget _dropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChange) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal:12),
      decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(
        side: const BorderSide(width:1.24, color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(14))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: value, isExpanded: true,
        hint: Text(hint, style: const TextStyle(color: Color(0x7F0A0A0A), fontSize:14, fontFamily:'Inter')),
        items: items.map((e) => DropdownMenuItem(value:e, child: Text(e, style: const TextStyle(fontFamily:'Inter', fontSize:14)))).toList(),
        onChanged: onChange,
      )));

  Widget _summaryRow(String label, String value, {Color? valueColor}) =>
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Color(0xFF525252), fontSize:14, fontFamily:'Inter')),
      Text(value, style: TextStyle(color: valueColor ?? const Color(0xFF171717), fontSize:14, fontFamily:'Inter', fontWeight:FontWeight.w700)),
    ]);
}
