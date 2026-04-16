import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addCompanyFieldsToUsers() async {
  final users = await FirebaseFirestore.instance.collection('users').get();
  
  for (var doc in users.docs) {
    await doc.reference.update({
      'location': doc['location'] ?? '—',
      'companySize': doc['companySize'] ?? '—',
      'industry': doc['industry'] ?? '—',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  print('✅ Updated ${users.docs.length} users');
}