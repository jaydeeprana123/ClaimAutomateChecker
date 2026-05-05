import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/login_screen.dart';
import '../../claims/new_claim_screen.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.lightGrey)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const Text('Menu', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                _buildNavItem(Icons.dashboard_rounded, 'Dashboard', isActive: true),
                _buildNavItem(Icons.inbox_rounded, 'Inbox', badgeCount: '3'),
                _buildNavItem(Icons.account_balance_wallet_rounded, 'Accounts'),
                _buildNavItem(Icons.trending_up_rounded, 'Analytics'),
                _buildNavItem(Icons.calendar_today_rounded, 'Meetings', badgeCount: '5'),
                
                const SizedBox(height: 24),
                const Text('Settings & Prefs', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                _buildNavItem(Icons.settings_rounded, 'Settings'),
                _buildNavItem(Icons.notifications_rounded, 'Daily Beat'),
              ],
            ),
          ),
          _buildQuickActions(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_user_rounded, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Panel', style: AppTextStyles.label),
                Text('Claim System', style: AppTextStyles.caption),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, {bool isActive = false, String? badgeCount}) {
    final color = isActive ? AppColors.primary : AppColors.darkGrey;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: badgeCount != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount,
                  style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {},
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewClaimScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.white),
              ),
              const SizedBox(height: 12),
              const Text('Create New Claim', style: AppTextStyles.label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined, color: AppColors.darkGrey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
