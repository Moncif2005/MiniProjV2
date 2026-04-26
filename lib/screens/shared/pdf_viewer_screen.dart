import '../../l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import '../../theme/app_colors.dart';

// class PdfViewerScreen extends StatelessWidget {
//   final String fileUrl;
//   const PdfViewerScreen({super.key, required this.fileUrl});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
    
//     return Scaffold(
//       backgroundColor: c.bg,
//       appBar: AppBar(
//         backgroundColor: c.surface,
//         title: Text(AppLocalizations.of(context).viewDocument, 
//           style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.close_rounded, color: c.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           // ✅ زر لإعادة التحميل إذا لزم الأمر
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
//             onPressed: () {
//               // يمكن إعادة تحميل الصفحة هنا
//             },
//           ),
//         ],
//       ),
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(url: WebUri(fileUrl)),
//         initialSettings: InAppWebViewSettings(
//           mediaPlaybackRequiresUserGesture: false,
//           allowFileAccess: true,
//           allowContentAccess: true,
//           useShouldOverrideUrlLoading: true,
//           // ✅ تحسينات للـ PDF
//           supportZoom: true,
//           useHybridComposition: true,
//         ),
//         onLoadStart: (controller, url) {
//           print('📄 Loading PDF...');
//         },
//         onLoadStop: (controller, url) {
//           print('✅ PDF loaded successfully');
//         },
//         onProgressChanged: (controller, progress) {
//           print('📊 Progress: $progress%');
//         },
//         onLoadError: (controller, url, code, message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: $message'),
//               backgroundColor: AppColors.red,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }