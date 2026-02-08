import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/firestore_refs.dart';
import '../../utils/user_roles.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  Future<void> _createBooking(
    BuildContext context,
    String serviceId,
    String providerId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirestoreRefs.bookings().add({
        'serviceId': serviceId,
        'providerId': providerId,
        'seekerId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request sent.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating booking: $e')),
        );
      }
    }
  }

  Future<void> _createRequest(
    BuildContext context,
    String serviceId,
    String providerId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirestoreRefs.requests().add({
        'serviceId': serviceId,
        'providerId': providerId,
        'seekerId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service request created.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirestoreRefs.services().doc(serviceId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() ?? {};
        final providerId = (data['providerId'] ?? '').toString();

        return Scaffold(
          appBar: AppBar(title: Text(data['title'] ?? 'Service')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  data['category'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text('Location: ${data['location'] ?? ''}'),
                Text('Price: LKR ${data['price'] ?? ''}'),
                const SizedBox(height: 12),
                Text(data['description'] ?? ''),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirestoreRefs.reviews()
                      .where('serviceId', isEqualTo: serviceId)
                      .snapshots(),
                  builder: (context, reviewSnapshot) {
                    final reviews = reviewSnapshot.data?.docs ?? [];
                    if (reviews.isEmpty) {
                      return const Text('No reviews yet.');
                    }
                    final ratings = reviews
                        .map((doc) => (doc.data()['rating'] ?? 0) as int)
                        .toList();
                    if (ratings.isEmpty) {
                      return const Text('No reviews yet.');
                    }
                    final avg = ratings.fold<int>(0, (sum, item) => sum + item) /
                        ratings.length;
                    return Text('Average rating: ${avg.toStringAsFixed(1)}');
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirestoreRefs.users().doc(user.uid).snapshots(),
                  builder: (context, roleSnapshot) {
                    final role =
                        (roleSnapshot.data?.data()?['role'] ?? UserRoles.seeker)
                            .toString();

                    if (role == UserRoles.provider) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _createBooking(context, serviceId, providerId),
                          child: const Text('Book Service'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () =>
                              _createRequest(context, serviceId, providerId),
                          child: const Text('Create Request'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
