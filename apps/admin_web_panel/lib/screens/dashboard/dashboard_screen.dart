import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_web_panel/services/admin_auth_service.dart';
import 'package:admin_web_panel/screens/authentication/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdminAuthService _authService = AdminAuthService();
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _currentUser?.email ?? 'Admin',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              // Handle navigation
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Usuários'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_car),
                selectedIcon: Icon(Icons.directions_car),
                label: Text('Motoristas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt),
                selectedIcon: Icon(Icons.receipt),
                label: Text('Corridas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money),
                selectedIcon: Icon(Icons.attach_money),
                label: Text('Pagamentos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Configurações'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bem-vindo ao Admin Panel',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Olá, ${_currentUser?.email ?? "Admin"}! 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Dashboard Cards
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildDashboardCard(
                          title: 'Total de Usuários',
                          value: '1,234',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        _buildDashboardCard(
                          title: 'Total de Motoristas',
                          value: '456',
                          icon: Icons.directions_car,
                          color: Colors.green,
                        ),
                        _buildDashboardCard(
                          title: 'Corridas Ativas',
                          value: '89',
                          icon: Icons.receipt,
                          color: Colors.orange,
                        ),
                        _buildDashboardCard(
                          title: 'Receita Total',
                          value: 'R\$ 12.5K',
                          icon: Icons.attach_money,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
