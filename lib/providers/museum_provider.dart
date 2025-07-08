import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/museum_data.dart';

class MuseumProvider extends ChangeNotifier {
  // Museum data
  late Museum _museum;
  List<Artwork> _favoriteArtworks = [];
  bool _isLoading = true;
  int _selectedExhibitionIndex = 0;

  // Getter for museum data
  Museum get museum => _museum;

  List<Artwork> get favoriteArtworks => _favoriteArtworks;

  bool get isLoading => _isLoading;

  int get selectedExhibitionIndex => _selectedExhibitionIndex;

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load museum data
    _museum = Museum.louvreAbuDhabi();

    // Load favorite artworks from shared preferences
    await _loadFavorites();

    _isLoading = false;
    notifyListeners();
  }

  // Load favorite artworks from shared preferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteArtworkTitles = prefs.getStringList('favoriteArtworks') ?? [];

    _favoriteArtworks = [];

    // Add all featured artworks that are in favorites
    for (var artwork in _museum.featuredArtworks) {
      if (favoriteArtworkTitles.contains(artwork.title)) {
        _favoriteArtworks.add(artwork);
      }
    }

    // Add artworks from all exhibitions that are in favorites
    for (var exhibition in _museum.exhibitions) {
      for (var artwork in exhibition.artworks) {
        if (favoriteArtworkTitles.contains(artwork.title) &&
            !_favoriteArtworks.any(
              (element) => element.title == artwork.title,
            )) {
          _favoriteArtworks.add(artwork);
        }
      }
    }
  }

  // Toggle artwork favorite status
  Future<void> toggleFavorite(Artwork artwork) async {
    final isCurrentlyFavorite = _favoriteArtworks.any(
      (element) => element.title == artwork.title,
    );

    if (isCurrentlyFavorite) {
      _favoriteArtworks.removeWhere(
        (element) => element.title == artwork.title,
      );
    } else {
      _favoriteArtworks.add(artwork);
    }

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteArtworks',
      _favoriteArtworks.map((artwork) => artwork.title).toList(),
    );

    notifyListeners();
  }

  // Check if an artwork is a favorite
  bool isFavorite(Artwork artwork) {
    return _favoriteArtworks.any((element) => element.title == artwork.title);
  }

  // Set selected exhibition index
  void setSelectedExhibitionIndex(int index) {
    _selectedExhibitionIndex = index;
    notifyListeners();
  }

  // Get current exhibition
  Exhibition get currentExhibition {
    return _museum.exhibitions[_selectedExhibitionIndex];
  }
}
