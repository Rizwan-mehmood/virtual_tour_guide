import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tour_model.dart';
import '../models/exhibit_model.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';

class ExhibitSelectionScreen extends StatefulWidget {
  final List<TourExhibit> initialExhibits;

  const ExhibitSelectionScreen({Key? key, this.initialExhibits = const []})
    : super(key: key);

  @override
  State<ExhibitSelectionScreen> createState() => _ExhibitSelectionScreenState();
}

class _ExhibitSelectionScreenState extends State<ExhibitSelectionScreen> {
  List<TourExhibit> _selectedExhibits = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showIconicOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedExhibits = List.from(widget.initialExhibits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exhibits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedExhibits);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search exhibits',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildFilters(),
              ],
            ),
          ),
          const Divider(height: 1),

          // Selected exhibits count
          Container(
            color: AppTheme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: ${_selectedExhibits.length} exhibits',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (_selectedExhibits.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedExhibits.clear();
                      });
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // Exhibits list
          Expanded(child: _buildExhibitsList()),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedExhibits);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Confirm Selection (${_selectedExhibits.length})',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All'),
                _filterChip('Painting'),
                _filterChip('Sculpture'),
                _filterChip('Jewelry'),
                _filterChip('Ceramics'),
                _filterChip('Textile'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: _showIconicOnly,
          activeColor: AppTheme.primaryColor,
          onChanged: (value) {
            setState(() {
              _showIconicOnly = value;
            });
          },
        ),
        const Text('Iconic only'),
      ],
    );
  }

  Widget _filterChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'All';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildExhibitsList() {
    return Consumer<FirebaseProvider>(
      builder: (context, firebaseProvider, _) {
        final exhibits = firebaseProvider.exhibits;

        // Apply filters
        final filteredExhibits =
            exhibits.where((exhibit) {
              // Apply search query filter
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  exhibit.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  exhibit.artist.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

              // Apply category filter
              final matchesCategory =
                  _selectedCategory == 'All' ||
                  exhibit.type.toLowerCase() == _selectedCategory.toLowerCase();

              // Apply iconic filter
              final matchesIconic = !_showIconicOnly || exhibit.isIconic;

              return matchesSearch && matchesCategory && matchesIconic;
            }).toList();

        if (filteredExhibits.isEmpty) {
          return const Center(child: Text('No exhibits match your filters'));
        }

        return ListView.builder(
          itemCount: filteredExhibits.length,
          itemBuilder: (context, index) {
            final exhibit = filteredExhibits[index];
            final isSelected = _selectedExhibits.any(
              (e) => e.exhibitId == exhibit.id,
            );

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(exhibit.imageUrl),
                  radius: 24,
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image loading errors
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child:
                        isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                  ),
                ),
                title: Text(
                  exhibit.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${exhibit.artist} • ${exhibit.type}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (exhibit.isIconic)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.star, color: Colors.amber, size: 18),
                      ),
                    SizedBox(
                      width: 100,
                      child: _buildDurationSelector(exhibit),
                    ),
                  ],
                ),
                onTap: () {
                  _toggleExhibitSelection(exhibit);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDurationSelector(Exhibit exhibit) {
    // Find if this exhibit is already selected
    final selectedIndex = _selectedExhibits.indexWhere(
      (e) => e.exhibitId == exhibit.id,
    );
    final isSelected = selectedIndex != -1;
    final duration =
        isSelected ? _selectedExhibits[selectedIndex].visitDurationMinutes : 15;

    return isSelected
        ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              onPressed: () {
                if (duration > 5) {
                  setState(() {
                    _selectedExhibits[selectedIndex] =
                        _selectedExhibits[selectedIndex].copyWith(
                          visitDurationMinutes: duration - 5,
                        );
                  });
                }
              },
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                '$duration min',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _selectedExhibits[selectedIndex] =
                      _selectedExhibits[selectedIndex].copyWith(
                        visitDurationMinutes: duration + 5,
                      );
                });
              },
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        )
        : OutlinedButton(
          onPressed: () {
            _toggleExhibitSelection(exhibit);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Add'),
        );
  }

  void _toggleExhibitSelection(Exhibit exhibit) {
    setState(() {
      final selectedIndex = _selectedExhibits.indexWhere(
        (e) => e.exhibitId == exhibit.id,
      );

      if (selectedIndex != -1) {
        // Remove if already selected
        _selectedExhibits.removeAt(selectedIndex);
      } else {
        // Add with correct order index
        _selectedExhibits.add(
          TourExhibit(
            exhibitId: exhibit.id,
            name: exhibit.name,
            imageUrl: exhibit.imageUrl,
            orderIndex: _selectedExhibits.length,
            visitDurationMinutes: 15,
          ),
        );
      }
    });
  }
}
