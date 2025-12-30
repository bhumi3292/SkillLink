import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_state.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AdminCubit>()..fetchDashboardStats(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        appBar: AppBar(
          title: const Text(
            'Admin Governance Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF003366),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic> stats = {
              'totalWorkers': 0,
              'pendingVerifications': 0,
              'activeHirers': 0,
              'ongoingBookings': 0,
              'totalReports': 0,
              'suspendedUsers': 0,
            };

            if (state is AdminDashboardLoaded) {
              stats = state.stats;
            }

            return RefreshIndicator(
              onRefresh: () => context.read<AdminCubit>().fetchDashboardStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          context,
                          'Total Workers',
                          '${stats['totalWorkers']}',
                          Icons.engineering,
                          Colors.blue,
                          route: '/admin/users',
                        ),
                        _buildStatCard(
                          context,
                          'Pending Requests',
                          '${stats['pendingRequests']}',
                          Icons.pending_actions,
                          Colors.orange,
                          route: '/admin/worker-requests',
                        ),
                        _buildStatCard(
                          context,
                          'Active Hirers',
                          '${stats['activeHirers']}',
                          Icons.people,
                          Colors.green,
                          route: '/admin/users',
                        ),
                        _buildStatCard(
                          context,
                          'Ongoing Bookings',
                          '${stats['ongoingBookings']}',
                          Icons.calendar_today,
                          Colors.purple,
                          route: '/admin/bookings',
                        ),
                        _buildStatCard(
                          context,
                          'Open Disputes',
                          '${stats['openDisputes']}',
                          Icons.gavel,
                          Colors.red,
                          route: '/admin/disputes',
                        ),
                        _buildStatCard(
                          context,
                          'Total Payments',
                          'Rs ${stats['totalPaymentsAmount'] ?? 0}',
                          Icons.payments,
                          Colors.teal,
                          route:
                              '/payment-history', // Or a dedicated admin payment view
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Management Console',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildManagementTile(
                      context,
                      'Service Categories',
                      'Update and manage categories',
                      Icons.category,
                      Colors.indigo,
                      () {
                        Navigator.pushNamed(context, '/admin/categories');
                      },
                    ),
                    _buildManagementTile(
                      context,
                      'User Directory',
                      'Manage workers and hirers',
                      Icons.supervised_user_circle,
                      Colors.teal,
                      () {
                        Navigator.pushNamed(context, '/admin/users');
                      },
                    ),
                    _buildManagementTile(
                      context,
                      'Dispute Resolution',
                      'Review reports and chats',
                      Icons.security,
                      Colors.deepOrange,
                      () {
                        Navigator.pushNamed(context, '/admin/disputes');
                      },
                    ),
                    _buildManagementTile(
                      context,
                      'Promotional Banners',
                      'Manage home page banners',
                      Icons.photo_library,
                      Colors.teal,
                      () {
                        Navigator.pushNamed(context, '/admin/banners');
                      },
                    ),
                    _buildManagementTile(
                      context,
                      'Analytics & Logs',
                      'System performance and audit logs',
                      Icons.insights,
                      Colors.blueGrey,
                      () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? route,
  }) {
    return InkWell(
      onTap: () {
        if (route != null) {
          if (route == '/payment-history')
             Navigator.pushNamed(context, '/admin/payments'); // Redirect to consistent route if needed
          else 
             Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
