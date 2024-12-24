import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemDetailScreen extends StatefulWidget {
  final String problemId;

  ProblemDetailScreen({required this.problemId});

  @override
  _ProblemDetailScreenState createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> {
  Map<String, dynamic>? _problemData;
  String? _errorMessage;
  bool _isLoading = true;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProblemDetails();
  }

  // Fetch problem details from Firestore
  void _fetchProblemDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('problems')
          .doc(widget.problemId)
          .get();

      if (doc.exists) {
        setState(() {
          _problemData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Problem not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading problem details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Function to add a vote
  void _addVote() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('problems')
          .doc(widget.problemId);

      await docRef.update({
        'votes': FieldValue.increment(1),
      });

      setState(() {
        _problemData!['votes'] += 1;
      });
    } catch (e) {
      print("Error adding vote: $e");
    }
  }

  // Function to submit a comment
  void _submitComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('problems')
          .doc(widget.problemId);

      await docRef.update({
        'comments': FieldValue.arrayUnion([_commentController.text.trim()]),
      });

      setState(() {
        _commentController.clear();
      });

      _fetchProblemDetails(); // Refresh problem details to show the new comment
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Problem Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.purple[800], // Purple background
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Problem Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.purple[800],
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Problem Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[800], // Purple background
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with "Issue:" label
            Text(
              'Issue: ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800], // Purple color for header
              ),
            ),
            Text(
              _problemData!['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black, // Black for title text
              ),
            ),
            const SizedBox(height: 20),

            // Description with "Detail:" label
            Text(
              'Detail: ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800], // Purple color for header
              ),
            ),
            Text(
              _problemData!['description'] ?? 'No Description',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87, // Slightly lighter text for description
              ),
            ),
            const SizedBox(height: 20),

            // Vote Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Votes: ${_problemData!['votes']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black for vote text
                  ),
                ),
                ElevatedButton(
                  onPressed: _addVote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.purple[800], // Purple for vote button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Vote',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Comment Section
            Text(
              'Comments:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800], // Purple for heading
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _problemData!['comments']?.length ?? 0,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.purple[50], // Light purple card
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _problemData!['comments'][index] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add Comment Input
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50], // Light purple background
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                  ),
                ],
              ),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Add a comment...',
                  labelStyle: TextStyle(color: Colors.purple[700]),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.purple[800], // Purple for comment button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Submit Comment',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
