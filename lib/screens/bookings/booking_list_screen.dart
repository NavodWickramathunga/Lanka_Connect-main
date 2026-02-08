import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/firestore_refs.dart';
import '../../utils/user_roles.dart';
import '../chat/chat_screen.dart';
import '../reviews/review_form_screen.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  Future<void> _updateStatus(String bookingId, String status) async {
    await FirestoreRefs.bookings().doc(bookingId).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirestoreRefs.users().doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final role = (snapshot.data?.data()?['role'] ?? UserRoles.seeker)
            .toString();

        Query<Map<String, dynamic>> query = FirestoreRefs.bookings();
        if (role == UserRoles.provider) {
          query = query.where('providerId', isEqualTo: user.uid);
        } else {
          query = query.where('seekerId', isEqualTo: user.uid);
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: query.snapshots(),
          builder: (context, bookingSnapshot) {
            if (bookingSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = bookingSnapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No bookings yet.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final status = (data['status'] ?? 'pending').toString();
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text('Service: ${data['serviceId']}'),
                    subtitle: Text('Status: $status'),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: doc.id),
                            ),
                          ),
                        ),
                        if (role == UserRoles.provider && status == 'pending')
                          TextButton(
                            onPressed: () => _updateStatus(doc.id, 'accepted'),
                            child: const Text('Accept'),
                          ),
                        if (role == UserRoles.provider && status == 'pending')
                          TextButton(
                            onPressed: () => _updateStatus(doc.id, 'rejected'),
                            child: const Text('Reject'),
                          ),
                        if (role == UserRoles.provider && status == 'accepted')
                          TextButton(
                            onPressed: () => _updateStatus(doc.id, 'completed'),
                            child: const Text('Complete'),
                          ),
                        if (role == UserRoles.seeker && status == 'completed')
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReviewFormScreen(
                                  bookingId: doc.id,
                                  serviceId: (data['serviceId'] ?? '').toString(),
                                  providerId:
                                      (data['providerId'] ?? '').toString(),
                                ),
                              ),
                            ),
                            child: const Text('Review'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
