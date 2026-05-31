import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/v2_colors.dart';
import '../theme/v2_typography.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard/pos')) return 1;
    if (location.startsWith('/dashboard/catalog')) return 2;
    if (location.startsWith('/dashboard/wallet')) return 3;
    if (location.startsWith('/dashboard/reports')) return 4;
    return 0; // Default to dashboard overview
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/dashboard/pos');
        break;
      case 2:
        context.go('/dashboard/catalog');
        break;
      case 3:
        context.go('/dashboard/wallet');
        break;
      case 4:
        context.go('/dashboard/reports');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final int currentIndex = _calculateSelectedIndex(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar 240px
            Container(
              width: 240,
              decoration: const BoxDecoration(
                color: V2Colors.cardBackground,
                border: Border(right: BorderSide(color: V2Colors.border)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: V2Colors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AntiRibet',
                          style: V2Typography.headingMd.copyWith(color: V2Colors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  _SidebarItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Overview',
                    isSelected: currentIndex == 0,
                    onTap: () => _onItemTapped(0, context),
                  ),
                  _SidebarItem(
                    icon: Icons.point_of_sale_outlined,
                    label: 'Kasir',
                    isSelected: currentIndex == 1,
                    onTap: () => _onItemTapped(1, context),
                  ),
                  _SidebarItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Katalog',
                    isSelected: currentIndex == 2,
                    onTap: () => _onItemTapped(2, context),
                  ),
                  _SidebarItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Saldo & Billing',
                    isSelected: currentIndex == 3,
                    onTap: () => _onItemTapped(3, context),
                  ),
                  _SidebarItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Laporan',
                    isSelected: currentIndex == 4,
                    onTap: () => _onItemTapped(4, context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: V2Colors.border)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (idx) => _onItemTapped(idx, context),
          backgroundColor: V2Colors.cardBackground,
          indicatorColor: V2Colors.primaryBlue.withOpacity(0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: V2Colors.primaryBlue),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale, color: V2Colors.primaryBlue),
              label: 'Kasir',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2, color: V2Colors.primaryBlue),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet, color: V2Colors.primaryBlue),
              label: 'Saldo',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: V2Colors.primaryBlue),
              label: 'Laporan',
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? V2Colors.primaryBlue : V2Colors.secondaryText;
    final bgColor = isSelected ? V2Colors.primaryBlue.withOpacity(0.1) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: V2Typography.labelLg.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
