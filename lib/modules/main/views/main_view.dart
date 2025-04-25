import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/dashboard/views/dashboard_view.dart';
import 'package:flutter_energy/modules/analytics/views/analytics_view.dart';
import 'package:flutter_energy/modules/home/views/home_view.dart';
import 'package:flutter_energy/modules/settings/views/settings_view.dart';
import 'package:flutter_energy/modules/main/controller/main_controller.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());
    
    final List<Widget> pages = [
      const HomeView(),
      const DashboardView(),
      const AnalyticsView(),
      const SettingsView(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: controller.changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      )),
    );
  }
}
