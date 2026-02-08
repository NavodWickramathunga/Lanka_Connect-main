import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/firestore_refs.dart';
import '../../utils/user_roles.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key, this.showOnlyMine = false});

  final bool showOnlyMine;

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  String _category = '';
  String _location = '';
  double? _minPrice;
  double? _maxPrice;

  @override
  void dispose() {
    _categoryController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _category = _categoryController.text.trim();
      _location = _locationController.text.trim();
      _minPrice = double.tryParse(_minPriceController.text.trim());
      _maxPrice = double.tryParse(_maxPriceController.text.trim());
    });
  }

  Query<Map<String, dynamic>> _buildQuery(String role, String userId) {
    Query<Map<String, dynamic>> query = FirestoreRefs.services();

    if (widget.showOnlyMine) {
      query = query.where('providerId', isEqualTo: userId);
    } else if (role == UserRoles.seeker) {
      query = query.where('status', isEqualTo: 'approved');
    }

    if (_category.isNotEmpty) {
      query = query.where('category', isEqualTo: _category);
    }

    if (_location.isNotEmpty) {
      query = query.where('location', isEqualTo: _location);
    }

    if (_minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: _minPrice);
    }

    if (_maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: _maxPrice);
    }

    return query.orderBy('price', descending: false);
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'City / District',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min price',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max price',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Filter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _buildQuery(role, user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No services found.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(data['title'] ?? 'Service'),
                          subtitle: Text(
                            '${data['category'] ?? ''} • ${data['location'] ?? ''} • LKR ${data['price'] ?? ''}',
                          ),
                          trailing: Text(
                            (data['status'] ?? 'pending').toString(),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(
                                serviceId: doc.id,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
