import 'package:flutter/material.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/local/local_storage_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'planner/ai_planner_screen.dart';
import 'farm/my_farm_screen.dart';
import 'catalog/crop_catalog_screen.dart';
import 'gamification/badges_screen.dart';
import 'marketplace/marketplace_screen.dart';

class MainShellScreen extends StatefulWidget {
  final LocalStorageService storageService;

  const MainShellScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        storageService: widget.storageService,
        onNavigateToPlanner: () => _navigateToIndex(1),
        onNavigateToGarden: () => _navigateToIndex(2),
        onNavigateToBadges: () => _navigateToIndex(5),
      ),
      AiPlannerScreen(
        onFarmCreated: () => _navigateToIndex(0),
      ),
      MyFarmScreen(
        onAddCropTap: () => _navigateToIndex(3),
      ),
      const CropCatalogScreen(),
      const MarketplaceScreen(),
      const BadgesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        indicatorColor: AppColors.primary.withAlpha(30),
        backgroundColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
            label: 'AI Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco, color: AppColors.primary),
            label: 'My Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Crops',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Color(0xFF00897B)),
            label: 'Marketplace',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppColors.streakOrange),
            label: 'Trophies',
          ),
        ],
      ),
    );
  }
}
