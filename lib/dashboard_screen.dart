import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to get the appropriate icon based on the problem category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'environment':
        return Icons.nature;
      case 'technology':
        return Icons.computer;
      case 'transportation':
        return Icons.directions_car;
      default:
        return Icons.lightbulb_outline; // Default icon if no match
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for the title
          ),
        ),
        backgroundColor: Colors.purple[800],
        centerTitle: true, // Purple background for AppBar
        elevation: 0, // No shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('problems').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No problems found.'));
          }

          final problems = snapshot.data!.docs;

          // Group problems by category
          Map<String, List<QueryDocumentSnapshot>> groupedProblems = {};
          for (var problem in problems) {
            final category = problem['category'] ?? 'Unknown';
            if (groupedProblems.containsKey(category)) {
              groupedProblems[category]!.add(problem);
            } else {
              groupedProblems[category] = [problem];
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: groupedProblems.entries.map((entry) {
                final category = entry.key;
                final problemsInCategory = entry.value;
                final icon = _getCategoryIcon(category);

                return Card(
                  elevation: 3,
                  color: Colors.white, // White background for card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.grey, // Light grey border
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Icon and Title
                        Row(
                          children: [
                            Icon(
                              icon,
                              size: 40,
                              color: Colors.purple[700], // Purple icon color
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .purple[800], // Purple for category title
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // List of Problems in the Category
                        ...problemsInCategory.map((problem) {
                          return Card(
                            elevation: 2,
                            color: Colors.purple[
                                50], // Light purple for each problem card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                problem['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Black text for titles
                                ),
                              ),
                              subtitle: Text(
                                problem['description'] ?? 'No Description',
                                style: const TextStyle(
                                  color:
                                      Colors.grey, // Grey text for description
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/problemDetail',
                                  arguments: {'problemId': problem.id},
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/postProblem');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.purple[700], // Purple for FAB
      ),
      backgroundColor: Colors.white, // White background for the body
    );
  }
}
