import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to add a news item
  Future<void> addNewsItem({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    await _firestore.collection('news').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'authorId': userId, // Store the user ID of the author
      'likes': [], // Initialize with empty list
      'timestamp': FieldValue.serverTimestamp(), // Add timestamp for ordering
    });
  }


  // Method to upload an image and return the URL
  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('news_images/$fileName');

    try {
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Method to toggle like on a news item with named parameters
  Future<void> toggleLike({
    required String newsItemId,
    required String userId,
  }) async {
    final docRef = _firestore.collection('news').doc(newsItemId);

    try {
      final doc = await docRef.get();
      final likes = List<String>.from(doc.data()?['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await docRef.update({'likes': likes});
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Method to get user info by userId
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      } else {
        print('No such user document!');
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }


  // Method to add a comment to a news item
  Future<void> addComment({
    required String newsItemId,
    required String comment,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    try {
      await _firestore.collection('news').doc(newsItemId).collection('comments').add({
        'userId': userId, // Store the userId of the commenter
        'comment': comment,
        'likes': [], // Initialize with empty list
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp for ordering
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Method to toggle like on a comment with named parameters
  Future<void> toggleCommentLike({
    required String newsItemId,
    required String commentId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    final commentDocRef = _firestore.collection('news').doc(newsItemId).collection('comments').doc(commentId);

    try {
      final commentDoc = await commentDocRef.get();
      final commentLikes = List<String>.from(commentDoc.data()?['likes'] ?? []);

      if (commentLikes.contains(userId)) {
        commentLikes.remove(userId);
      } else {
        commentLikes.add(userId);
      }

      await commentDocRef.update({'likes': commentLikes});
    } catch (e) {
      throw Exception('Failed to toggle comment like: $e');
    }
  }
}
