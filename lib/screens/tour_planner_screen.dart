import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/tour_model.dart';
import '../models/exhibit_model.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';
import 'tour_detail_screen.dart';
import 'create_tour_screen.dart';

class TourPlannerScreen extends StatefulWidget {
  const TourPlannerScreen({Key? key}) : super(key: key);

  @override
  State<TourPlannerScreen> createState() => _TourPlannerScreenState();
}

class _TourPlannerScreenState extends State<TourPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firebaseProvider = Provider.of<FirebaseProvider>(
        context,
        listen: false,
      );
      firebaseProvider.loadUserTours();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Calendar'),
            Tab(text: 'Past Tours'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: Consumer<FirebaseProvider>(
        builder: (context, firebaseProvider, _) {
          if (firebaseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTours = firebaseProvider.userTours;
          final upcomingTours =
              allTours
                  .where(
                    (tour) =>
                        !tour.isCancelled &&
                        tour.tourDate.isAfter(DateTime.now()),
                  )
                  .toList();
          final pastTours =
              allTours
                  .where(
                    (tour) =>
                        !tour.isCancelled &&
                        tour.tourDate.isBefore(DateTime.now()),
                  )
                  .toList();
          final cancelledTours =
              allTours.where((tour) => tour.isCancelled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming tours tab
              _buildUpcomingToursTab(upcomingTours),

              // Calendar tab
              _buildCalendarTab(allTours),

              // Past tours tab
              _buildPastToursTab(pastTours, cancelledTours),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTourScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingToursTab(List<Tour> upcomingTours) {
    if (upcomingTours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No upcoming tours',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan your next museum visit',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTourScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Create Tour'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingTours.length,
      itemBuilder: (context, index) {
        final tour = upcomingTours[index];
        return _buildTourCard(tour);
      },
    );
  }

  Widget _buildCalendarTab(List<Tour> allTours) {
    // Group tours by date
    final Map<DateTime, List<Tour>> toursByDate = {};
    for (final tour in allTours) {
      if (!tour.isCancelled) {
        final date = DateTime(
          tour.tourDate.year,
          tour.tourDate.month,
          tour.tourDate.day,
        );
        if (toursByDate[date] == null) {
          toursByDate[date] = [];
        }
        toursByDate[date]!.add(tour);
      }
    }

    return Column(
      children: [
        // Calendar
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          eventLoader: (day) {
            return toursByDate[DateTime(day.year, day.month, day.day)] ?? [];
          },
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0x99C8B273), // A lighter version of accentColor
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
        ),
        const Divider(),
        // Selected day tours
        Expanded(
          child:
              _selectedDay == null
                  ? const Center(child: Text('Select a day to view tours'))
                  : _buildSelectedDayTours(toursByDate),
        ),
      ],
    );
  }

  Widget _buildSelectedDayTours(Map<DateTime, List<Tour>> toursByDate) {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final toursOnSelectedDay = toursByDate[selectedDate] ?? [];

    if (toursOnSelectedDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'No tours planned for this day',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CreateTourScreen(initialDate: _selectedDay),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Plan Tour'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: toursOnSelectedDay.length,
            itemBuilder: (context, index) {
              final tour = toursOnSelectedDay[index];
              return _buildTourCard(tour);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPastToursTab(List<Tour> pastTours, List<Tour> cancelledTours) {
    if (pastTours.isEmpty && cancelledTours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No past tours',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tours you\'ve completed will appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pastTours.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Completed Tours',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          ...pastTours.map((tour) => _buildTourCard(tour)),
          const SizedBox(height: 16),
        ],

        if (cancelledTours.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
            child: Text(
              'Cancelled Tours',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          ...cancelledTours.map((tour) => _buildTourCard(tour)),
        ],
      ],
    );
  }

  Widget _buildTourCard(Tour tour) {
    final Color cardColor = tour.isCancelled ? Colors.grey[100]! : Colors.white;

    final Color textColor =
        tour.isCancelled ? Colors.grey : AppTheme.textPrimaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: tour.isCancelled ? 0 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Provider.of<FirebaseProvider>(
            context,
            listen: false,
          ).setCurrentTour(tour);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TourDetailScreen(tour: tour),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour date banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    tour.isCancelled
                        ? Colors.grey[300]
                        : AppTheme.primaryColor.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(tour.tourDate),
                    style: TextStyle(
                      color: tour.isCancelled ? Colors.grey[700] : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(tour.tourDate),
                    style: TextStyle(
                      color: tour.isCancelled ? Colors.grey[700] : Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Tour details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tour.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (tour.isCancelled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Cancelled',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tour.description,
                    style: TextStyle(color: textColor.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tour.exhibits.length} exhibits',
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                      Text(
                        '${tour.durationMinutes} mins',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: textColor,
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
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tour Planner Guide'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Planning Your Museum Visit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Create personalized tours with your favorite exhibits'),
                Text('• Schedule visits at your preferred date and time'),
                Text('• Add or remove exhibits from your tour'),
                Text('• View crowd information to plan accordingly'),
                SizedBox(height: 16),
                Text(
                  'Managing Your Tours',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Modify tour details at any time'),
                Text('• Cancel tours if your plans change'),
                Text('• Rate and review exhibits after your visit'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
