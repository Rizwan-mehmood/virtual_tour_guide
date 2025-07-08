import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tour_model.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';
import 'create_tour_screen.dart';
import 'artwork_details_screen.dart';
import 'exhibit_comment_screen.dart';

class TourDetailScreen extends StatelessWidget {
  final Tour tour;

  const TourDetailScreen({Key? key, required this.tour}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Details'),
        actions: [
          // Only show edit and more options if the tour is upcoming and not cancelled
          if (!tour.isCancelled && tour.tourDate.isAfter(DateTime.now()))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditTour(context),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder:
                (BuildContext context) => [
                  if (!tour.isCancelled &&
                      tour.tourDate.isAfter(DateTime.now()))
                    const PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text('Cancel Tour'),
                    ),
                  if (tour.isCancelled)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Tour'),
                    ),
                  if (tour.tourDate.isBefore(DateTime.now()) &&
                      !tour.isCancelled)
                    const PopupMenuItem<String>(
                      value: 'rate',
                      child: Text('Rate Exhibits'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: Text('Share Tour'),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour header
            Container(
              width: double.infinity,
              color:
                  tour.isCancelled
                      ? Colors.grey[200]
                      : AppTheme.primaryColor.withOpacity(0.9),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tour status badge
                  if (tour.isCancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Cancelled',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    tour.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tour.isCancelled ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'EEEE, MMMM d, yyyy • h:mm a',
                    ).format(tour.tourDate),
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          tour.isCancelled
                              ? Colors.grey[500]
                              : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tour.durationMinutes} minutes • ${tour.exhibits.length} exhibits',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          tour.isCancelled
                              ? Colors.grey[500]
                              : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Tour description
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tour.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Exhibits list
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tour Itinerary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!tour.isCancelled &&
                          tour.tourDate.isAfter(DateTime.now()))
                        TextButton.icon(
                          onPressed: () => _navigateToEditTour(context),
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExhibitsList(context),
                ],
              ),
            ),

            // Tour actions
            if (!tour.isCancelled)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (tour.tourDate.isAfter(DateTime.now()))
                      Column(
                        children: [
                          _buildActionButton(
                            context,
                            'Add to Calendar',
                            Icons.calendar_today,
                            Colors.blue,
                            () => _addToCalendar(context),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            context,
                            'Cancel Tour',
                            Icons.cancel,
                            Colors.red,
                            () => _confirmCancelTour(context),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildActionButton(
                            context,
                            'Rate Exhibits',
                            Icons.star,
                            Colors.amber,
                            () => _navigateToRateExhibits(context),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            context,
                            'Create Similar Tour',
                            Icons.copy,
                            Colors.teal,
                            () => _createSimilarTour(context),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitsList(BuildContext context) {
    if (tour.exhibits.isEmpty) {
      return const Card(
        color: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No exhibits in this tour'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tour.exhibits.length,
      itemBuilder: (context, index) {
        final exhibit = tour.exhibits[index];
        final isPast =
            tour.tourDate.isBefore(DateTime.now()) && !tour.isCancelled;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // Navigate to exhibit details
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exhibit image
                Stack(
                  children: [
                    Image.network(
                      exhibit.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (isPast)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap:
                              () => _navigateToExhibitRating(context, exhibit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.star, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Rate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Exhibit details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exhibit.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Duration: ${exhibit.visitDurationMinutes} minutes',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Planned time: ${_calculateExhibitTime(index)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Calculate the planned time for an exhibit based on its position in the tour
  String _calculateExhibitTime(int index) {
    int totalMinutesBefore = 0;
    for (int i = 0; i < index; i++) {
      totalMinutesBefore += tour.exhibits[i].visitDurationMinutes;
    }

    final exhibitTime = DateTime(
      tour.tourDate.year,
      tour.tourDate.month,
      tour.tourDate.day,
      tour.tourDate.hour,
      tour.tourDate.minute + totalMinutesBefore,
    );

    return DateFormat('h:mm a').format(exhibitTime);
  }

  // Navigation and action methods
  void _navigateToEditTour(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTourScreen(tourToEdit: tour),
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tour updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'cancel':
        _confirmCancelTour(context);
        break;
      case 'delete':
        _confirmDeleteTour(context);
        break;
      case 'rate':
        _navigateToRateExhibits(context);
        break;
      case 'share':
        _shareTour(context);
        break;
    }
  }

  void _confirmCancelTour(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Tour'),
          content: const Text(
            'Are you sure you want to cancel this tour? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelTour(context);
              },
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelTour(BuildContext context) async {
    try {
      await Provider.of<FirebaseProvider>(
        context,
        listen: false,
      ).cancelTour(tour.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tour cancelled successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling tour: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDeleteTour(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tour'),
          content: const Text(
            'Are you sure you want to permanently delete this tour? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTour(context);
              },
              child: const Text(
                'Yes, Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTour(BuildContext context) async {
    try {
      await Provider.of<FirebaseProvider>(
        context,
        listen: false,
      ).deleteTour(tour.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tour deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tour: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToRateExhibits(BuildContext context) {
    // Navigate to a screen where the user can rate all exhibits in the tour
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select an exhibit to rate'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToExhibitRating(BuildContext context, TourExhibit exhibit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExhibitCommentScreen(
              exhibitId: exhibit.exhibitId,
              exhibitName: exhibit.name,
              imageUrl: exhibit.imageUrl,
            ),
      ),
    );
  }

  void _addToCalendar(BuildContext context) {
    // Add the tour to the user's calendar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tour added to calendar'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createSimilarTour(BuildContext context) {
    // Create a new tour with the same exhibits but a new date
    final newTourDate = DateTime.now().add(const Duration(days: 7));
    final newTour = Tour(
      userId: tour.userId,
      title: '${tour.title} (Copy)',
      description: tour.description,
      tourDate: newTourDate,
      exhibits: tour.exhibits,
      createdAt: DateTime.now(),
      durationMinutes: tour.durationMinutes,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTourScreen(tourToEdit: newTour),
      ),
    );
  }

  void _shareTour(BuildContext context) {
    // Share the tour details with others
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing tour details...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
