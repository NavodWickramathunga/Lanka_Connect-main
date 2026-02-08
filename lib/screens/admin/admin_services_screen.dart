import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/firestore_refs.dart';

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  Future<void> _updateStatus(String serviceId, String status) async {
    try {
      await FirestoreRefs.services().doc(serviceId).update({'status': status});
    } catch (e) {
      // Error will be silently caught as there's no BuildContext here
      // In a production app, you might want to use a state management solution
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreRefs.services()
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No pending services.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(data['title'] ?? 'Service'),
                subtitle: Text(data['category'] ?? ''),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => _updateStatus(doc.id, 'approved'),
                      child: const Text('Approve'),
                    ),
                    TextButton(
                      onPressed: () => _updateStatus(doc.id, 'rejected'),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
