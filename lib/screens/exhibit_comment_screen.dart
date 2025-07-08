import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../models/exhibit_comment.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';

class ExhibitCommentScreen extends StatefulWidget {
  final String exhibitId;
  final String exhibitName;
  final String imageUrl;

  const ExhibitCommentScreen({
    Key? key,
    required this.exhibitId,
    required this.exhibitName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ExhibitCommentScreen> createState() => _ExhibitCommentScreenState();
}

class _ExhibitCommentScreenState extends State<ExhibitCommentScreen> {
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<String> _selectedTags = [];

  ExhibitComment? _userComment;

  @override
  void initState() {
    super.initState();
    _checkIfUserAlreadyCommented();
  }

  Future<void> _checkIfUserAlreadyCommented() async {
    final firebaseProvider = Provider.of<FirebaseProvider>(
      context,
      listen: false,
    );
    final currentUser = firebaseProvider.currentUser;

    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final comment = await firebaseProvider.getUserCommentForExhibit(
      exhibitId: widget.exhibitId,
      userId: currentUser.uid,
    );

    if (comment != null) {
      setState(() {
        _userComment = comment;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate & Comment')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          _userComment != null
                              ? _buildSubmittedReview()
                              : _buildReviewForm(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            stops: const [0.6, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exhibitName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Submitted Review',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            RatingBarIndicator(
              rating: _userComment!.rating,
              itemBuilder:
                  (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 24,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 8),
            Text(
              _getRatingText(_userComment!.rating),
              style: TextStyle(fontSize: 16, color: AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_userComment!.comment, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you rate this exhibit?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: RatingBar.builder(
            initialRating: _rating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder:
                (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(_rating),
            style: TextStyle(
              fontSize: 16,
              color: _rating > 0 ? AppTheme.primaryColor : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'What did you like about it?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTagChip('Inspiring'),
            _buildTagChip('Beautiful'),
            _buildTagChip('Informative'),
            _buildTagChip('Well presented'),
            _buildTagChip('Historical value'),
            _buildTagChip('Unique'),
            _buildTagChip('Technical skill'),
            _buildTagChip('Cultural significance'),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Share your thoughts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Write your comment here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting || _rating == 0 ? null : _submitComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTags.add(tag);
          } else {
            _selectedTags.remove(tag);
          }
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black,
      ),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  String _getRatingText(double rating) {
    if (rating == 0) return 'Tap to rate';
    if (rating <= 1) return 'Poor';
    if (rating <= 2) return 'Fair';
    if (rating <= 3) return 'Good';
    if (rating <= 4) return 'Very Good';
    return 'Excellent';
  }

  Future<void> _submitComment() async {
    if (_rating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final firebaseProvider = Provider.of<FirebaseProvider>(
        context,
        listen: false,
      );
      final currentUser = firebaseProvider.currentUser;
      final userProfile = firebaseProvider.userProfile;

      if (currentUser == null || userProfile == null) {
        throw Exception('User not authenticated or profile not found');
      }

      String commentText = _commentController.text.trim();
      if (_selectedTags.isNotEmpty) {
        commentText = "$commentText\n\nHighlights: ${_selectedTags.join(', ')}";
      }

      final comment = ExhibitComment(
        exhibitId: widget.exhibitId,
        userId: currentUser.uid,
        userName: userProfile.name,
        userAvatarUrl: userProfile.avatarUrl,
        comment: commentText,
        rating: _rating,
        createdAt: DateTime.now(),
      );

      await firebaseProvider.addExhibitComment(comment);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your review!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
