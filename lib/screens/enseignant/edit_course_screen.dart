import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../models/course_model.dart';
import '../../services/cloudinary_service.dart';
import '../../services/courses_service.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;
  const EditCourseScreen({super.key, required this.courseId});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _certPriceCtrl;
  
  // State
  CourseModel? _course;
  bool _isLoading = true;
  bool _isSaving = false;
  
  File? _newImageFile;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _certPriceCtrl = TextEditingController();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    final course = await CoursesService().getCourseById(widget.courseId);
    if (course != null && mounted) {
      setState(() {
        _course = course;
        _titleCtrl.text = course.title;
        _descCtrl.text = course.description;
        _priceCtrl.text = course.coursePrice.toString();
        _certPriceCtrl.text = course.certificatePrice.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _newImageFile = File(image.path);
      _isUploadingImage = true;
    });

    try {
      final url = await CloudinaryService.upload(
        file: _newImageFile!,
        folder: 'course_covers',
        resourceType: 'image',
      );

      if (url != null && mounted) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded!'), backgroundColor: AppColors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updates = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'coursePrice': double.tryParse(_priceCtrl.text) ?? 0.0,
        'certificatePrice': double.tryParse(_certPriceCtrl.text) ?? 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // إذا تم رفع صورة جديدة، نضيفها للتحديث
      if (_uploadedImageUrl != null) {
        updates['imageUrl'] = _uploadedImageUrl;
      }

      await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully!'), backgroundColor: AppColors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _certPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_isLoading) {
      return Scaffold(backgroundColor: c.bg, body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text('Edit Course', style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary), onPressed: () => Navigator.pop(context)),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(
              onPressed: _saveChanges,
              child: Text('Save', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Center(
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: c.inputBg,
                          image: _uploadedImageUrl != null
                              ? DecorationImage(image: NetworkImage(_uploadedImageUrl!), fit: BoxFit.cover)
                              : (_course?.imageUrl != null && _course!.imageUrl!.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(_course!.imageUrl!), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _uploadedImageUrl == null && (_course?.imageUrl == null || _course!.imageUrl!.isEmpty)
                            ? Icon(Icons.add_a_photo, size: 48, color: c.textMuted)
                            : null,
                      ),
                      if (_isUploadingImage)
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildField('Course Title', _titleCtrl, c),
              const SizedBox(height: 16),
              _buildField('Description', _descCtrl, c, maxLines: 4),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildField('Price (€)', _priceCtrl, c, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Cert. Price (€)', _certPriceCtrl, c, keyboardType: TextInputType.number)),
                ],
              ),
              
              const SizedBox(height: 32),
              Text('Note: To edit lessons or units, please use the "Create Course" flow or contact support.', 
                   style: TextStyle(color: c.textMuted, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, ThemeColors c, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: (val) => val!.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}