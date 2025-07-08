import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/tour_model.dart';
import '../models/user_profile.dart';
import '../models/exhibit_comment.dart';
import '../models/crowd_data.dart';

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  final CollectionReference _toursCollection = FirebaseFirestore.instance
      .collection('tours');
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _commentsCollection = FirebaseFirestore.instance
      .collection('comments');
  final CollectionReference _exhibitsCollection = FirebaseFirestore.instance
      .collection('exhibits');
  final CollectionReference _crowdDataCollection = FirebaseFirestore.instance
      .collection('crowd_data');

  // Authentication
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // For demonstration purposes, create a guest user
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // User Profile Methods
  // User Profile Methods
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // Get the user document
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _usersCollection.doc(userId).get();

      if (!doc.exists) return null;

      final userData = doc.data()!;

      // Fetch comment count for the user
      final commentSnap =
          await _commentsCollection.where('userId', isEqualTo: userId).get();

      final commentCount = commentSnap.size;

      // Add comment count to user data map
      userData['commentCount'] = commentCount;

      // Pass modified map to UserProfile.fromMap
      return UserProfile.fromMap(userData, doc.id);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.userId).set(profile.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.userId).update(profile.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Tour Methods
  Future<List<Tour>> getUserTours(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _toursCollection
              .where('userId', isEqualTo: userId)
              .orderBy('tourDate', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => Tour.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error getting user tours: $e');
      return [];
    }
  }

  Future<Tour?> getTour(String tourId) async {
    try {
      DocumentSnapshot doc = await _toursCollection.doc(tourId).get();
      if (doc.exists) {
        return Tour.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting tour: $e');
      return null;
    }
  }

  Future<String> createTour(Tour tour) async {
    try {
      DocumentReference docRef = await _toursCollection.add(tour.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating tour: $e');
      return '';
    }
  }

  Future<void> updateTour(Tour tour) async {
    try {
      await _toursCollection.doc(tour.id).update(tour.toMap());
    } catch (e) {
      print('Error updating tour: $e');
    }
  }

  Future<void> deleteTour(String tourId) async {
    try {
      await _toursCollection.doc(tourId).delete();
    } catch (e) {
      print('Error deleting tour: $e');
    }
  }

  // Exhibit Comments Methods
  Future<List<ExhibitComment>> getExhibitComments(String exhibitId) async {
    try {
      QuerySnapshot querySnapshot =
          await _commentsCollection
              .where('exhibitId', isEqualTo: exhibitId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => ExhibitComment.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting exhibit comments: $e');
      return [];
    }
  }

  Future<String> addExhibitComment(ExhibitComment comment) async {
    try {
      DocumentReference docRef = await _commentsCollection.add(comment.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding exhibit comment: $e');
      return '';
    }
  }

  Future<void> updateExhibitComment(ExhibitComment comment) async {
    try {
      await _commentsCollection.doc(comment.id).update(comment.toMap());
    } catch (e) {
      print('Error updating exhibit comment: $e');
    }
  }

  Future<void> deleteExhibitComment(String commentId) async {
    try {
      await _commentsCollection.doc(commentId).delete();
    } catch (e) {
      print('Error deleting exhibit comment: $e');
    }
  }

  // Crowd Data Methods
  Future<CrowdData?> getCurrentCrowdData() async {
    try {
      // Typically you'd use a specific document ID for current crowd data
      // or query based on a timestamp
      QuerySnapshot querySnapshot =
          await _crowdDataCollection
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CrowdData.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting crowd data: $e');
      return null;
    }
  }

  Future<void> updateCrowdData(CrowdData crowdData) async {
    try {
      // Update or create a new crowd data document
      await _crowdDataCollection.doc(crowdData.id).set(crowdData.toMap());
    } catch (e) {
      print('Error updating crowd data: $e');
    }
  }

  // AI Chatbot - This would typically integrate with a backend API
  // For Firebase, we could store conversation history
  Future<void> saveChatHistory(
    String userId,
    String question,
    String answer,
  ) async {
    try {
      await _firestore.collection('chat_history').add({
        'userId': userId,
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }
}
