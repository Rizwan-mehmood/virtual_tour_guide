import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import 'dart:math';

class DataService extends ChangeNotifier {
  final SharedPreferences _prefs;

  // In-memory storage
  User? _currentUser;
  List<Exhibit> _exhibits = [];
  List<Tour> _tours = [];
  Map<String, int> _crowdData = {}; // Location -> visitor count

  // Keys for SharedPreferences
  static const String _currentUserKey = 'current_user';
  static const String _exhibitsKey = 'exhibits';
  static const String _toursKey = 'tours';
  static const String _crowdDataKey = 'crowd_data';

  // Constructor
  DataService(this._prefs);

  // Getters
  User? get currentUser => _currentUser;

  List<Exhibit> get exhibits => _exhibits;

  List<Tour> get tours =>
      _tours.where((tour) => tour.userId == _currentUser?.id).toList();

  Map<String, int> get crowdData => _crowdData;

  // Initialize data - load from SharedPreferences or create sample data
  Future<void> initializeData() async {
    await _loadCurrentUser();
    await _loadExhibits();
    await _loadTours();
    await _loadCrowdData();

    // If no exhibits found, create sample data
    if (_exhibits.isEmpty) {
      _createSampleExhibits();
      _saveExhibits();
    }

    // Initialize crowd data if empty
    if (_crowdData.isEmpty) {
      _createSampleCrowdData();
      _saveCrowdData();
    }

    notifyListeners();
  }

  // Load current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    final userJson = _prefs.getString(_currentUserKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  // Load exhibits from SharedPreferences
  Future<void> _loadExhibits() async {
    final exhibitsJson = _prefs.getString(_exhibitsKey);
    if (exhibitsJson != null) {
      final List<dynamic> decodedList = jsonDecode(exhibitsJson);
      _exhibits = decodedList.map((item) => Exhibit.fromJson(item)).toList();
    }
  }

  // Load tours from SharedPreferences
  Future<void> _loadTours() async {
    final toursJson = _prefs.getString(_toursKey);
    if (toursJson != null) {
      final List<dynamic> decodedList = jsonDecode(toursJson);
      _tours = decodedList.map((item) => Tour.fromJson(item)).toList();
    }
  }

  // Load crowd data from SharedPreferences
  Future<void> _loadCrowdData() async {
    final crowdDataJson = _prefs.getString(_crowdDataKey);
    if (crowdDataJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(crowdDataJson);
      _crowdData = decoded.map((key, value) => MapEntry(key, value as int));
    }
  }

  // Save current user to SharedPreferences
  Future<void> _saveCurrentUser() async {
    if (_currentUser != null) {
      await _prefs.setString(
        _currentUserKey,
        jsonEncode(_currentUser!.toJson()),
      );
    }
  }

  // Save exhibits to SharedPreferences
  Future<void> _saveExhibits() async {
    final exhibitsJson = jsonEncode(_exhibits.map((e) => e.toJson()).toList());
    await _prefs.setString(_exhibitsKey, exhibitsJson);
  }

  // Save tours to SharedPreferences
  Future<void> _saveTours() async {
    final toursJson = jsonEncode(_tours.map((t) => t.toJson()).toList());
    await _prefs.setString(_toursKey, toursJson);
  }

  // Save crowd data to SharedPreferences
  Future<void> _saveCrowdData() async {
    await _prefs.setString(_crowdDataKey, jsonEncode(_crowdData));
  }

  // Create sample exhibits for demo purposes
  void _createSampleExhibits() {
    _exhibits = [
      Exhibit(
        name: 'La Belle Ferronnière',
        description:
            'This portrait by Leonardo da Vinci is one of only 15 known paintings by the Renaissance master. It portrays a woman from the court of Milan and showcases da Vinci\'s mastery of light and shadow.',
        imageUrl: 'https://example.com/belle_ferronniere.jpg',
        category: 'Painting',
        location: 'Gallery 1',
        period: '1490-1495',
        artistNames: ['Leonardo da Vinci'],
        reviews: [],
      ),
      Exhibit(
        name: 'Bactrian Princess',
        description:
            'This small female statuette from Central Asia dates to the late 3rd to early 2nd millennium BCE. It represents a stylized female figure and is carved from a soft stone such as chlorite or steatite.',
        imageUrl: 'https://example.com/bactrian_princess.jpg',
        category: 'Sculpture',
        location: 'Gallery 2',
        period: '2500-1500 BCE',
        artistNames: ['Unknown'],
        reviews: [],
      ),
      Exhibit(
        name: 'The Saint-Lazare Station',
        description:
            'Claude Monet\'s depiction of the bustling Gare Saint-Lazare in Paris is one of a series of twelve paintings of this subject. It captures the steam, smoke, and technology of the industrial age through Monet\'s impressionist technique.',
        imageUrl: 'https://example.com/saint_lazare_station.jpg',
        category: 'Painting',
        location: 'Gallery 3',
        period: '1877',
        artistNames: ['Claude Monet'],
        reviews: [],
      ),
      Exhibit(
        name: 'Fountain of Light',
        description:
            'This contemporary sculpture by Ai Weiwei is inspired by the famous Tatlin\'s Tower (Monument to the Third International). Made of crystal and LED lights, it stands over 7 meters tall and references both Eastern and Western architectural traditions.',
        imageUrl: 'https://example.com/fountain_of_light.jpg',
        category: 'Installation',
        location: 'Gallery 4',
        period: '2007',
        artistNames: ['Ai Weiwei'],
        reviews: [],
      ),
      Exhibit(
        name: 'Madonna and Child',
        description:
            'A beautiful Renaissance painting depicting the Virgin Mary holding the infant Jesus. This work exemplifies the religious art of the period with its rich colors and emotional intensity.',
        imageUrl: 'https://example.com/madonna_child.jpg',
        category: 'Painting',
        location: 'Gallery 5',
        period: '15th century',
        artistNames: ['Giovanni Bellini'],
        reviews: [],
      ),
      Exhibit(
        name: 'Ancient Egyptian Sarcophagus',
        description:
            'This elaborately decorated sarcophagus from ancient Egypt features intricate hieroglyphics and religious imagery. It was designed to protect the mummy of a high-ranking official.',
        imageUrl: 'https://example.com/egyptian_sarcophagus.jpg',
        category: 'Artifact',
        location: 'Gallery 6',
        period: 'c. 1200 BCE',
        artistNames: ['Unknown'],
        reviews: [],
      ),
      Exhibit(
        name: 'The Dome',
        description:
            'The iconic dome of Louvre Abu Dhabi, designed by Jean Nouvel, is a modern architectural masterpiece. The 7,500-ton steel structure creates a "rain of light" effect, inspired by palm fronds in traditional Arabic architecture.',
        imageUrl: 'https://example.com/the_dome.jpg',
        category: 'Architecture',
        location: 'Exterior',
        period: '2017',
        artistNames: ['Jean Nouvel'],
        reviews: [],
      ),
      Exhibit(
        name: 'Monumental Statue of Ramesses II',
        description:
            'This colossal statue depicts the Egyptian pharaoh Ramesses II (1279-1213 BCE), one of Egypt\'s most powerful rulers. The statue exemplifies the grand scale and formal style of official ancient Egyptian royal portraiture.',
        imageUrl: 'https://example.com/ramesses_statue.jpg',
        category: 'Sculpture',
        location: 'Gallery 7',
        period: '13th century BCE',
        artistNames: ['Unknown'],
        reviews: [],
      ),
    ];
  }

  // Create sample crowd data
  void _createSampleCrowdData() {
    _crowdData = {
      'Gallery 1': 25,
      'Gallery 2': 18,
      'Gallery 3': 32,
      'Gallery 4': 15,
      'Gallery 5': 22,
      'Gallery 6': 10,
      'Gallery 7': 28,
      'Entrance Hall': 45,
      'Café': 12,
      'Museum Shop': 20,
    };
  }

  // Simulate crowd changes (for demonstration)
  void updateCrowdData() {
    final random = Random();
    _crowdData.forEach((key, value) {
      // Randomly adjust crowd numbers within ±5 people
      int change = random.nextInt(11) - 5;
      int newValue = max(0, value + change);
      _crowdData[key] = newValue;
    });
    _saveCrowdData();
    notifyListeners();
  }

  // User authentication methods (placeholders for Firebase integration)

  // Sign in user
  Future<bool> signIn(String email, String password) async {
    // Simulate authentication
    // In a real app, this would validate with Firebase
    // For demo purposes, create a mock user if none exists

    // Check if user exists (simple mock)
    if (email == 'demo@example.com' && password == 'password') {
      _currentUser = User(
        id: 'user123',
        username: 'Demo User',
        email: 'demo@example.com',
        profileImage: '',
        favoriteExhibitIds: [],
        preferences: {
          'language': 'English',
          'notificationsEnabled': true,
          'theme': 'light',
          'preferredCategories': ['Painting', 'Sculpture'],
        },
      );
      await _saveCurrentUser();
      notifyListeners();
      return true;
    }

    // Create new mock user for testing
    _currentUser = User(
      username: email.split('@')[0],
      email: email,
      profileImage: '',
      favoriteExhibitIds: [],
      preferences: {
        'language': 'English',
        'notificationsEnabled': true,
        'theme': 'light',
      },
    );
    await _saveCurrentUser();
    notifyListeners();
    return true;
  }

  // Sign out user
  Future<void> signOut() async {
    _currentUser = null;
    await _prefs.remove(_currentUserKey);
    notifyListeners();
  }

  // Register new user
  Future<bool> register(String username, String email, String password) async {
    // Simulate registration
    // In a real app, this would create a user in Firebase
    _currentUser = User(
      username: username,
      email: email,
      profileImage: '',
      favoriteExhibitIds: [],
      preferences: {
        'language': 'English',
        'notificationsEnabled': true,
        'theme': 'light',
      },
    );
    await _saveCurrentUser();
    notifyListeners();
    return true;
  }

  // Update user profile
  Future<void> updateUserProfile(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveCurrentUser();
    notifyListeners();
  }

  // Toggle favorite exhibit
  Future<void> toggleFavoriteExhibit(String exhibitId) async {
    if (_currentUser == null) return;

    List<String> updatedFavorites = List.from(_currentUser!.favoriteExhibitIds);
    if (updatedFavorites.contains(exhibitId)) {
      updatedFavorites.remove(exhibitId);
    } else {
      updatedFavorites.add(exhibitId);
    }

    _currentUser = _currentUser!.copyWith(favoriteExhibitIds: updatedFavorites);
    await _saveCurrentUser();
    notifyListeners();
  }

  // Get user's favorite exhibits
  List<Exhibit> getFavoriteExhibits() {
    if (_currentUser == null) return [];
    return _exhibits
        .where(
          (exhibit) => _currentUser!.favoriteExhibitIds.contains(exhibit.id),
        )
        .toList();
  }

  // Tour management methods

  // Create a new tour
  Future<void> createTour(Tour tour) async {
    _tours.add(tour);
    await _saveTours();
    notifyListeners();
  }

  // Update an existing tour
  Future<void> updateTour(Tour updatedTour) async {
    final index = _tours.indexWhere((tour) => tour.id == updatedTour.id);
    if (index != -1) {
      _tours[index] = updatedTour;
      await _saveTours();
      notifyListeners();
    }
  }

  // Cancel a tour
  Future<void> cancelTour(String tourId) async {
    final index = _tours.indexWhere((tour) => tour.id == tourId);
    if (index != -1) {
      _tours[index] = _tours[index].cancel();
      await _saveTours();
      notifyListeners();
    }
  }

  // Delete a tour
  Future<void> deleteTour(String tourId) async {
    _tours.removeWhere((tour) => tour.id == tourId);
    await _saveTours();
    notifyListeners();
  }

  // Get active tours (not cancelled)
  List<Tour> getActiveTours() {
    if (_currentUser == null) return [];
    return _tours
        .where(
          (tour) =>
              tour.userId == _currentUser!.id && tour.status != 'cancelled',
        )
        .toList();
  }

  // Exhibit review methods

  // Add a review to an exhibit
  Future<void> addReview(
    String exhibitId,
    double rating,
    String comment,
  ) async {
    if (_currentUser == null) return;

    final index = _exhibits.indexWhere((exhibit) => exhibit.id == exhibitId);
    if (index != -1) {
      final review = Review(
        userId: _currentUser!.id,
        username: _currentUser!.username,
        rating: rating,
        comment: comment,
      );

      _exhibits[index] = _exhibits[index].addReview(review);
      await _saveExhibits();
      notifyListeners();
    }
  }

  // Get exhibits by category
  List<Exhibit> getExhibitsByCategory(String category) {
    return _exhibits.where((exhibit) => exhibit.category == category).toList();
  }

  // Get the most popular exhibits (highest rated)
  List<Exhibit> getPopularExhibits({int limit = 5}) {
    final sortedExhibits = List<Exhibit>.from(_exhibits)
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sortedExhibits.take(limit).toList();
  }
}
