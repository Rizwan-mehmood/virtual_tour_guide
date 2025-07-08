import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/museum_provider.dart';
import '../models/museum_data.dart';
import '../theme.dart';
import '../widgets/custom_widgets.dart';

class VisitorInfoScreen extends StatefulWidget {
  const VisitorInfoScreen({Key? key}) : super(key: key);

  @override
  State<VisitorInfoScreen> createState() => _VisitorInfoScreenState();
}

class _VisitorInfoScreenState extends State<VisitorInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Function to launch Google Maps with the museum location
  Future<void> _launchMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MuseumProvider>(
      builder: (context, museumProvider, _) {
        final museum = museumProvider.museum;
        final visitorInfo = museum.visitorInfo;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Visit Information'),
            backgroundColor: Colors.white,
            elevation: 2,
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // Map Section
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
                  ),
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                  ),
                  child: Stack(
                    children: [
                      // Map image
                      CachedNetworkImage(
                        imageUrl: visitorInfo.mapUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.map_outlined,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Map not available'),
                                  ],
                                ),
                              ),
                            ),
                      ),
                      // Address overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'LOCATION',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      visitorInfo.location['address'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _launchMap(
                                    visitorInfo.location['latitude'] as double,
                                    visitorInfo.location['longitude'] as double,
                                  );
                                },
                                icon: const Icon(
                                  Icons.directions,
                                  color: Colors.white,
                                ),
                                label: const Text('Directions'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Opening Hours Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.2,
                        0.8,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Opening Hours',
                                  style: AppTheme.textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visitorInfo.openingHours.length,
                              itemBuilder: (context, index) {
                                final day = visitorInfo.openingHours[index].day;
                                final hours =
                                    visitorInfo.openingHours[index].hours;
                                final isToday =
                                    day ==
                                    _getDayOfWeek(DateTime.now().weekday);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          if (isToday)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green,
                                              ),
                                            ),
                                          Text(
                                            day,
                                            style: TextStyle(
                                              fontWeight:
                                                  isToday
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color:
                                                  isToday
                                                      ? AppTheme.primaryColor
                                                      : AppTheme
                                                          .textPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        hours,
                                        style: TextStyle(
                                          fontWeight:
                                              isToday
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              hours == 'Closed'
                                                  ? Colors.red
                                                  : AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Ticket Prices Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.3,
                        0.9,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.confirmation_number,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ticket Prices',
                                  style: AppTheme.textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Ticket prices
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visitorInfo.ticketPrices.length,
                              itemBuilder: (context, index) {
                                final ticket = visitorInfo.ticketPrices[index];
                                final isFree = ticket.price == 'Free';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ticket.type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isFree
                                                  ? Colors.green.withOpacity(
                                                    0.1,
                                                  )
                                                  : AppTheme.primaryColor
                                                      .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          ticket.price,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isFree
                                                    ? Colors.green[700]
                                                    : AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Book tickets button
                            SizedBox(
                              width: double.infinity,
                              child: AppWidgets.gradientButton(
                                'Book Tickets Online',
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Opening ticket booking...',
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Facilities Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.4,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_cafe,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Facilities & Services',
                                  style: AppTheme.textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Facilities grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: visitorInfo.facilities.length,
                              itemBuilder: (context, index) {
                                final facility = visitorInfo.facilities[index];
                                final IconData iconData = _getFacilityIcon(
                                  facility,
                                );

                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          iconData,
                                          color: AppTheme.primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            facility,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Additional Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.5,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Information',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppWidgets.infoSection(
                          'Photography Policy',
                          'Photography is permitted for personal, non-commercial use. Flash, tripods, and selfie sticks are not permitted inside the galleries.',
                          Icons.camera_alt,
                        ),
                        AppWidgets.infoSection(
                          'Accessibility',
                          'The museum is fully accessible for visitors with reduced mobility. Wheelchairs are available free of charge at the Information Desk.',
                          Icons.accessible,
                        ),
                        AppWidgets.infoSection(
                          'Guided Tours',
                          'Daily guided tours are available in English, Arabic, and French. Check at the information desk for schedules.',
                          Icons.group,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to get day of week as string
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  // Helper function to get icon for facility
  IconData _getFacilityIcon(String facility) {
    if (facility.contains('Restaurant') || facility.contains('Café')) {
      return Icons.restaurant;
    } else if (facility.contains('Shop')) {
      return Icons.shopping_bag;
    } else if (facility.contains('Prayer')) {
      return Icons.brightness_4;
    } else if (facility.contains('WiFi')) {
      return Icons.wifi;
    } else if (facility.contains('Wheelchair')) {
      return Icons.accessible;
    } else if (facility.contains('Coat')) {
      return Icons.checkroom;
    } else if (facility.contains('ATM')) {
      return Icons.atm;
    } else if (facility.contains('First Aid')) {
      return Icons.medical_services;
    } else {
      return Icons.info_outline;
    }
  }
}
