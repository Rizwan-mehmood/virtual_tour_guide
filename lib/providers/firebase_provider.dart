import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_service.dart';
import '../models/tour_model.dart';
import '../models/user_profile.dart';
import '../models/exhibit_model.dart';
import '../models/exhibit_comment.dart';
import '../models/crowd_data.dart';
import '../models/museum_data.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // User state
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';

  // Tours
  List<Tour> _userTours = [];
  Tour? _currentTour;

  // Exhibits
  List<Exhibit> _exhibits = [];
  List<Exhibit> _iconicExhibits = [];

  // Comments
  Map<String, List<ExhibitComment>> _exhibitComments = {};

  // Crowd data
  CrowdData? _crowdData;

  // Getters
  User? get currentUser => _currentUser;

  UserProfile? get userProfile {
    final profile = _userProfile;
    if (profile != null) {
      // Print the whole object or individual fields
      debugPrint(
        '🌟 UserProfile loaded: '
        'name=${profile.name}, '
        'email=${profile.email}, '
        'avatarUrl=${profile.avatarUrl}, '
        'completedTours=${profile.completedTours}',
      );
    } else {
      debugPrint('⚠️ UserProfile is null');
    }
    return profile;
  }

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  List<Tour> get userTours => _userTours;

  Tour? get currentTour => _currentTour;

  List<Exhibit> get exhibits => _exhibits;

  List<Exhibit> get iconicExhibits => _iconicExhibits;

  Map<String, List<ExhibitComment>> get exhibitComments => _exhibitComments;

  CrowdData? get crowdData => _crowdData;

  // Initialize the provider
  // In firebase_provider.dart
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Just get current user (no anonymous sign-in)
      _currentUser = await _firebaseService.getCurrentUser();

      if (_currentUser != null) {
        await loadUserProfile();
        await loadUserTours();
        _loadMockExhibits();
        _loadMockCrowdData();
      }

      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      _userProfile = await _firebaseService.getUserProfile(_currentUser!.uid);

      // If profile doesn't exist, create a default one
      if (_userProfile == null) {
        _userProfile = UserProfile(
          userId: _currentUser!.uid,
          name: 'Guest User',
          email: _currentUser!.email ?? '',
          avatarUrl: '',
          favoriteExhibitTypes: [],
          favoriteExhibits: [],
          completedTours: [],
          preferences: {},
        );

        await _firebaseService.createUserProfile(_userProfile!);
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
    }

    notifyListeners();
  }

  Future<void> loginUser(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _currentUser = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );
      await loadUserProfile();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e);
    } catch (e) {
      _errorMessage = 'Login failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ExhibitComment?> getUserCommentForExhibit({
    required String exhibitId,
    required String userId,
  }) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('comments')
            .where('exhibitId', isEqualTo: exhibitId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return ExhibitComment.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }

    return null;
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }

  Future<void> registerUser(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _currentUser = await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );
      await loadUserProfile();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e);
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _firebaseService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e);
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update user profile: $e';
      notifyListeners();
    }
  }

  // Load user tours
  Future<void> loadUserTours() async {
    if (_currentUser == null) return;

    try {
      _userTours = await _firebaseService.getUserTours(_currentUser!.uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load tours: $e';
      notifyListeners();
    }
  }

  // Create a new tour
  Future<String> createTour(Tour tour) async {
    try {
      final tourId = await _firebaseService.createTour(tour);
      if (tourId.isNotEmpty) {
        final createdTour = tour.copyWith(id: tourId);
        _userTours.add(createdTour);
        _currentTour = createdTour;
        notifyListeners();
      }
      return tourId;
    } catch (e) {
      _errorMessage = 'Failed to create tour: $e';
      notifyListeners();
      return '';
    }
  }

  // Update a tour
  Future<void> updateTour(Tour updatedTour) async {
    try {
      await _firebaseService.updateTour(updatedTour);

      // Update local tour list
      final index = _userTours.indexWhere((tour) => tour.id == updatedTour.id);
      if (index != -1) {
        _userTours[index] = updatedTour;
      }

      if (_currentTour?.id == updatedTour.id) {
        _currentTour = updatedTour;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update tour: $e';
      notifyListeners();
    }
  }

  // Cancel a tour
  Future<void> cancelTour(String tourId) async {
    try {
      final tourIndex = _userTours.indexWhere((tour) => tour.id == tourId);
      if (tourIndex != -1) {
        final updatedTour = _userTours[tourIndex].copyWith(isCancelled: true);
        await _firebaseService.updateTour(updatedTour);

        _userTours[tourIndex] = updatedTour;

        if (_currentTour?.id == tourId) {
          _currentTour = updatedTour;
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to cancel tour: $e';
      notifyListeners();
    }
  }

  // Delete a tour
  Future<void> deleteTour(String tourId) async {
    try {
      await _firebaseService.deleteTour(tourId);

      _userTours.removeWhere((tour) => tour.id == tourId);

      if (_currentTour?.id == tourId) {
        _currentTour = null;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete tour: $e';
      notifyListeners();
    }
  }

  // Set current tour
  void setCurrentTour(Tour tour) {
    _currentTour = tour;
    notifyListeners();
  }

  // Load comments for an exhibit
  Future<void> loadExhibitComments(String exhibitId) async {
    try {
      if (!_exhibitComments.containsKey(exhibitId)) {
        final comments = await _firebaseService.getExhibitComments(exhibitId);
        _exhibitComments[exhibitId] = comments;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load comments: $e';
      notifyListeners();
    }
  }

  // Add a comment to an exhibit
  Future<void> addExhibitComment(ExhibitComment comment) async {
    try {
      final commentId = await _firebaseService.addExhibitComment(comment);
      if (commentId.isNotEmpty) {
        final updatedComment = comment.copyWith(id: commentId);

        if (_exhibitComments.containsKey(comment.exhibitId)) {
          _exhibitComments[comment.exhibitId]!.insert(0, updatedComment);
        } else {
          _exhibitComments[comment.exhibitId] = [updatedComment];
        }

        // Update the exhibit's rating if it exists in our collection
        final exhibitIndex = _exhibits.indexWhere(
          (exhibit) => exhibit.id == comment.exhibitId,
        );
        if (exhibitIndex != -1) {
          final exhibit = _exhibits[exhibitIndex];
          final totalRating = exhibit.averageRating * exhibit.ratingCount;
          final newRatingCount = exhibit.ratingCount + 1;
          final newAverageRating =
              (totalRating + comment.rating) / newRatingCount;

          _exhibits[exhibitIndex] = exhibit.copyWith(
            averageRating: newAverageRating,
            ratingCount: newRatingCount,
          );
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add comment: $e';
      notifyListeners();
    }
  }

  // Load current crowd data
  Future<void> loadCrowdData() async {
    try {
      _crowdData = await _firebaseService.getCurrentCrowdData();

      // If no crowd data is available, use mock data
      if (_crowdData == null) {
        _loadMockCrowdData();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load crowd data: $e';
      notifyListeners();
    }
  }

  // Mock data loading methods (for development and testing)
  void _loadMockExhibits() {
    // Convert artwork items from museum data to exhibits
    final museum = Museum.louvreAbuDhabi();

    // Convert featured artworks to exhibits
    _exhibits =
        museum.featuredArtworks.map((artwork) {
          return Exhibit(
            id: artwork.title.replaceAll(' ', '_').toLowerCase(),
            name: artwork.title,
            description: artwork.description,
            imageUrl: artwork.imageUrl,
            type: artwork.type,
            location: 'Main Gallery',
            artist: artwork.artist,
            period: artwork.year,
            origin: 'Unknown',
            isIconic: true,
            tags: [artwork.type, artwork.artist, artwork.year],
            averageRating: 4.5,
            // Mock average rating
            ratingCount: 120, // Mock rating count
          );
        }).toList();

    // Add additional exhibits from exhibitions
    for (var exhibition in museum.exhibitions) {
      for (var artwork in exhibition.artworks) {
        _exhibits.add(
          Exhibit(
            id: artwork.title.replaceAll(' ', '_').toLowerCase(),
            name: artwork.title,
            description: artwork.description,
            imageUrl: artwork.imageUrl,
            type: artwork.type,
            location: exhibition.title,
            artist: artwork.artist,
            period: artwork.year,
            origin: 'Unknown',
            isIconic: true,
            tags: [artwork.type, artwork.artist, artwork.year],
            averageRating: 4.0,
            // Mock average rating
            ratingCount: 80, // Mock rating count
          ),
        );
      }
    }

    // Set iconic exhibits
    _iconicExhibits = _exhibits.where((exhibit) => exhibit.isIconic).toList();
  }

  void _loadMockCrowdData() {
    final now = DateTime.now();

    final Map<String, int> mockVisitorsBySection = {
      'Main Gallery': 45,
      'East Wing': 30,
      'West Wing': 25,
      'Special Exhibition': 80,
      'Islamic Art': 20,
      'European Art': 15,
    };

    final Map<String, List<CrowdTimeData>> mockCrowdForecast = {
      'Main Gallery': _generateMockTimeData(),
      'East Wing': _generateMockTimeData(),
      'West Wing': _generateMockTimeData(),
      'Special Exhibition': _generateMockTimeData(),
      'Islamic Art': _generateMockTimeData(),
      'European Art': _generateMockTimeData(),
    };

    _crowdData = CrowdData(
      id: 'mock_crowd_data',
      timestamp: now,
      totalVisitors: mockVisitorsBySection.values.reduce((a, b) => a + b),
      visitorsBySection: mockVisitorsBySection,
      crowdForecast: mockCrowdForecast,
    );
  }

  List<CrowdTimeData> _generateMockTimeData() {
    final List<CrowdTimeData> mockData = [];

    final List<String> timeSlots = [
      '09:00-10:00',
      '10:00-11:00',
      '11:00-12:00',
      '12:00-13:00',
      '13:00-14:00',
      '14:00-15:00',
      '15:00-16:00',
      '16:00-17:00',
      '17:00-18:00',
      '18:00-19:00',
    ];

    final List<String> crowdLevels = ['Low', 'Medium', 'High'];

    for (var i = 0; i < timeSlots.length; i++) {
      final expectedVisitors = 10 + (i * 5) + (i % 3 == 0 ? 20 : 0);
      final crowdLevel =
          i < 3 ? crowdLevels[0] : (i < 7 ? crowdLevels[1] : crowdLevels[2]);

      mockData.add(
        CrowdTimeData(
          timeSlot: timeSlots[i],
          expectedVisitors: expectedVisitors,
          crowdLevel: crowdLevel,
        ),
      );
    }

    return mockData;
  }
}
