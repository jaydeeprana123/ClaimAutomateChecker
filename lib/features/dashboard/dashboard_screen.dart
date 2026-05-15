import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/sidebar_menu.dart';
import 'widgets/main_content_area.dart';
import 'widgets/right_panel.dart';
import '../patients/patient_list_screen.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 800 && screenWidth <= 1200;

    Widget buildBody() {
      return Obx(() {
        switch (controller.selectedIndex.value) {
          case 0:
            return const MainContentArea();
          case 1:
            return const PatientListScreen();
          default:
            return const MainContentArea();
        }
      });
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            const SidebarMenu(),
            Expanded(child: buildBody()),
            Obx(() => controller.selectedIndex.value == 0 ? const RightPanel() : const SizedBox.shrink()),
          ],
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: const Drawer(child: SidebarMenu()),
        body: Row(
          children: [
            Expanded(child: buildBody()),
            Obx(() => controller.selectedIndex.value == 0 ? const RightPanel() : const SizedBox.shrink()),
          ],
        ),
      );
    } else {
      // Mobile view
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primaryDark,
          elevation: 1,
          title: Obx(() => Text(
                controller.selectedIndex.value == 0 ? 'Dashboard' : 'Patients',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        drawer: const Drawer(child: SidebarMenu()),
        endDrawer: const Drawer(child: RightPanel()),
        body: buildBody(),
      );
    }
  }
}
