import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/crowd_data.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';
import 'dart:math';

class CrowdMonitorScreen extends StatefulWidget {
  const CrowdMonitorScreen({Key? key}) : super(key: key);

  @override
  State<CrowdMonitorScreen> createState() => _CrowdMonitorScreenState();
}

class _CrowdMonitorScreenState extends State<CrowdMonitorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSection = 'Main Gallery';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FirebaseProvider>(context, listen: false).loadCrowdData();
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
        title: const Text('Crowd Monitor'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Current Status'), Tab(text: 'Forecast')],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: Consumer<FirebaseProvider>(
        builder: (context, firebaseProvider, _) {
          if (firebaseProvider.isLoading ||
              firebaseProvider.crowdData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final crowdData = firebaseProvider.crowdData!;

          return TabBarView(
            controller: _tabController,
            children: [
              // Current Status tab
              _buildCurrentStatusTab(crowdData),

              // Forecast tab
              _buildForecastTab(crowdData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatusTab(CrowdData crowdData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current time and total visitors
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current Status as of ${DateFormat('h:mm a').format(crowdData.timestamp)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${crowdData.totalVisitors}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Current Visitors',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildCrowdLevelIndicator(crowdData.totalVisitors),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section breakdown
          const Text(
            'Visitors by Section',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildVisitorsBySection(crowdData),
          ),
          const SizedBox(height: 24),

          // Section details
          const Text(
            'Section Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSectionDetails(crowdData),
        ],
      ),
    );
  }

  Widget _buildForecastTab(CrowdData crowdData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section selector
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a section to view forecast:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          crowdData.visitorsBySection.keys.map((section) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(section),
                                selected: _selectedSection == section,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedSection = section;
                                    });
                                  }
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: AppTheme.primaryColor
                                    .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color:
                                      _selectedSection == section
                                          ? AppTheme.primaryColor
                                          : Colors.black,
                                  fontWeight:
                                      _selectedSection == section
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Today's forecast
          Text(
            'Forecast for $_selectedSection',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildForecastChart(crowdData),
          ),
          const SizedBox(height: 24),

          // Best times to visit
          const Text(
            'Best Times to Visit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBestTimesToVisit(crowdData),
        ],
      ),
    );
  }

  Widget _buildCrowdLevelIndicator(int totalVisitors) {
    String crowdLevel;
    Color levelColor;

    if (totalVisitors < 100) {
      crowdLevel = 'Low';
      levelColor = Colors.green;
    } else if (totalVisitors < 200) {
      crowdLevel = 'Moderate';
      levelColor = Colors.orange;
    } else {
      crowdLevel = 'High';
      levelColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 12, color: levelColor),
          const SizedBox(width: 8),
          Text(
            'Crowd Level: $crowdLevel',
            style: TextStyle(color: levelColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorsBySection(CrowdData data) {
    final sections = data.visitorsBySection;
    final maxY = sections.values.reduce(max) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // removed tooltipBgColor
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name = sections.keys.elementAt(groupIndex);
              final cnt = sections.values.elementAt(groupIndex);
              return BarTooltipItem(
                '$name\n$cnt visitors',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, TitleMeta meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sections.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      sections.keys.elementAt(idx),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: List.generate(sections.length, (i) {
          final cnt = sections.values.elementAt(i).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: cnt,
                color: AppTheme.primaryColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionDetails(CrowdData crowdData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: crowdData.visitorsBySection.length,
      itemBuilder: (context, index) {
        final sectionName = crowdData.visitorsBySection.keys.elementAt(index);
        final visitors = crowdData.visitorsBySection.values.elementAt(index);

        String crowdLevel;
        Color levelColor;

        if (visitors < 20) {
          crowdLevel = 'Low';
          levelColor = Colors.green;
        } else if (visitors < 50) {
          crowdLevel = 'Moderate';
          levelColor = Colors.orange;
        } else {
          crowdLevel = 'High';
          levelColor = Colors.red;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(sectionName),
            subtitle: Text('$visitors visitors'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                crowdLevel,
                style: TextStyle(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForecastChart(CrowdData data) {
    final forecast = data.crowdForecast[_selectedSection] ?? [];
    if (forecast.isEmpty) {
      return const Center(child: Text('No forecast data'));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            // removed tooltipBgColor
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final slot = forecast[spot.x.toInt()].timeSlot;
                final cnt = forecast[spot.x.toInt()].expectedVisitors;
                return LineTooltipItem(
                  '$slot\n$cnt visitors',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, TitleMeta meta) {
                final idx = value.toInt();
                if (idx % 2 == 0 && idx < forecast.length) {
                  final slot = forecast[idx].timeSlot.split('-').first;
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(slot, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20,
          getDrawingHorizontalLine:
              (val) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        maxY: forecast.map((e) => e.expectedVisitors).reduce(max) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              forecast.length,
              (i) =>
                  FlSpot(i.toDouble(), forecast[i].expectedVisitors.toDouble()),
            ),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestTimesToVisit(CrowdData crowdData) {
    final forecastData = crowdData.crowdForecast[_selectedSection] ?? [];

    if (forecastData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No forecast data available'),
        ),
      );
    }

    // Find the three time slots with the lowest expected visitors
    final sortedData = List.from(forecastData)
      ..sort((a, b) => a.expectedVisitors.compareTo(b.expectedVisitors));

    final bestTimes = sortedData.take(3).toList();

    return Column(
      children:
          bestTimes.map((time) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: const Icon(Icons.access_time, color: Colors.green),
                ),
                title: Text(time.timeSlot),
                subtitle: Text('Expected: ${time.expectedVisitors} visitors'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Recommended',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
