import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/museum_provider.dart';
import '../theme.dart';
import '../widgets/custom_widgets.dart';
import 'exhibition_screen.dart';
import 'visitor_info_screen.dart';
import 'artwork_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  // Universal Google Maps link for coordinates 24.533441,54.398537
  final Uri _mapUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=24.533441,54.398537',
  );

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scrollController = ScrollController()..addListener(_onScroll);

    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 180;
    if (shouldShow != _showAppBarTitle) {
      setState(() => _showAppBarTitle = shouldShow);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    if (await canLaunchUrl(_mapUri)) {
      await launchUrl(_mapUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MuseumProvider>(
      builder: (context, museumProvider, _) {
        if (museumProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
              ),
            ),
          );
        }

        final museum = museumProvider.museum;
        final fadeAnimation = CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOut,
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: _showAppBarTitle ? 2 : 0,
            backgroundColor:
                _showAppBarTitle ? Colors.white : Colors.transparent,
            foregroundColor: AppTheme.textPrimaryColor,
            title:
                _showAppBarTitle
                    ? Text(
                      museum.name,
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite, color: AppTheme.primaryColor),
                onPressed: () {
                  final count = museumProvider.favoriteArtworks.length;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        count == 0
                            ? 'You have no favorite artworks yet'
                            : 'You have $count favorite artworks',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Main Image
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: Container(
                        height: 380,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: museum.mainImageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),

                    // Title + Buttons Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  museum.name,
                                  style: AppTheme.textTheme.displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 10,
                                            color: Colors.black54,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Architect: ${museum.architectName} • Opened: ${museum.yearOpened}',
                                  style: AppTheme.textTheme.titleSmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppWidgets.gradientButton(
                                        'Plan Your Visit',
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const VisitorInfoScreen(),
                                            ),
                                          );
                                        },
                                        gradient: AppTheme.primaryGradient,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.location_on,
                                          color: AppTheme.primaryColor,
                                        ),
                                        onPressed: _openMap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content: About, Facts, Gallery, Exhibitions
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: const Interval(
                        0.3,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // About the Museum
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
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
                                      Icons.info_outline,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'About the Museum',
                                      style: AppTheme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                museum.description,
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        MuseumFactsWidget(facts: museum.facts),
                        const SizedBox(height: 8),
                        AppWidgets.sectionTitle('Gallery'),
                        GalleryCarousel(images: museum.galleryImages),
                        const SizedBox(height: 24),
                        AppWidgets.sectionTitle(
                          'Current Exhibitions',
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExhibitionScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Exhibition List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= museum.exhibitions.length) return null;
                  final exhibition = museum.exhibitions[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Interval(
                          0.4 + index * 0.1,
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fadeController,
                        curve: Interval(
                          0.4 + index * 0.1,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ExhibitionPreview(
                          exhibition: exhibition,
                          onTap: () {
                            museumProvider.setSelectedExhibitionIndex(index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExhibitionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }, childCount: museum.exhibitions.length),
              ),

              // Featured Artworks
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppWidgets.sectionTitle('Featured Artworks'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final artwork = museum.featuredArtworks[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _slideController,
                          curve: Interval(
                            0.6 + index * 0.05,
                            1.0,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _fadeController,
                          curve: Interval(
                            0.6 + index * 0.05,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: ArtworkGridItem(
                          artwork: artwork,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ArtworkDetailsScreen(artwork: artwork),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }, childCount: museum.featuredArtworks.length),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
