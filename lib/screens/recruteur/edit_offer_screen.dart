import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/offers_service.dart';

class EditOfferScreen extends StatefulWidget {
  final Map<String, dynamic> offer;
  const EditOfferScreen({super.key, required this.offer});

  @override
  State<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _descCtrl;
  String? _selectedType;
  bool _isSaving = false;

  final _jobTypes = ['Full-time', 'Part-time', 'Remote', 'Hybrid', 'Contract'];
  final _offersService = OffersService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.offer['title']);
    _locationCtrl = TextEditingController(text: widget.offer['location']);
    _salaryCtrl = TextEditingController(text: widget.offer['salary']);
    _descCtrl = TextEditingController(text: widget.offer['description']);
    _selectedType = widget.offer['jobType'];
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _locationCtrl.dispose();
    _salaryCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Job title is required'), backgroundColor: AppColors.red,
      ));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await _offersService.updateOffer(
        offerId: widget.offer['id'],
        title: _titleCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        salary: _salaryCtrl.text.trim(),
        jobType: _selectedType ?? 'Full-time',
        description: _descCtrl.text.trim(),
        company: widget.offer['company'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Job updated successfully ✓' : 'Failed to update'),
          backgroundColor: success ? AppColors.green : AppColors.red,
        ));
        if (success) Navigator.pop(context, true); // Return success flag
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: AppColors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Job', style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save', style: TextStyle(color: AppColors.purple, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Job Title *', c),
            const SizedBox(height: 8),
            _field(_titleCtrl, 'Ex: Senior Flutter Developer', c),
            const SizedBox(height: 16),

            _label('Location', c),
            const SizedBox(height: 8),
            _field(_locationCtrl, 'Ex: Paris, France or Remote', c),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Job Type', c),
                    const SizedBox(height: 8),
                    _dropdown(_selectedType, 'Select type', _jobTypes, (v) => setState(() => _selectedType = v), c),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Salary Range', c),
                    const SizedBox(height: 8),
                    _field(_salaryCtrl, 'Ex: \$80k–\$100k', c),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Job Description', c),
            const SizedBox(height: 8),
            _field(_descCtrl, 'Describe the role...', c, maxLines: 6),
            const SizedBox(height: 32),

            // Preview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.06),
                border: Border.all(color: AppColors.purple.withOpacity(0.3), width: 1.24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
                      child: const Icon(Icons.preview_rounded, color: Colors.white, size: 18)),
                    const SizedBox(width: 12),
                    Text('Preview', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 12),
                  _row('Title:', _titleCtrl.text, c),
                  const SizedBox(height: 6),
                  _row('Location:', _locationCtrl.text, c),
                  const SizedBox(height: 6),
                  _row('Type:', _selectedType ?? '—', c),
                  const SizedBox(height: 6),
                  _row('Salary:', _salaryCtrl.text, c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, ThemeColors c) => Text(text, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700));
  Widget _row(String label, String val, ThemeColors c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
    Text(val, style: TextStyle(color: c.textPrimary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
  ]);
  Widget _field(TextEditingController ctrl, String hint, ThemeColors c, {int maxLines = 1}) => Container(
    decoration: ShapeDecoration(color: c.inputBg, shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(14))),
    child: TextField(controller: ctrl, maxLines: maxLines, style: TextStyle(color: c.textPrimary),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
  );
  Widget _dropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChange, ThemeColors c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: ShapeDecoration(color: c.inputBg, shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(14))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, isExpanded: true, dropdownColor: c.surface,
      hint: Text(hint, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontSize: 14)))).toList(),
      onChanged: onChange,
    )),
  );
}