import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/admin_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/admin_state.dart';
import 'category_management_screen.dart';
import 'inventory_management_screen.dart';
import 'order_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          } else if (state is AdminLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<AdminCubit>().loadDashboardData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(context, state.stats),
                    const SizedBox(height: 24),
                    _buildShippingToggle(context, state.stats['isFreeShipping'] as bool),
                    const SizedBox(height: 24),
                    Text(
                      l10n.revenueTrend,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildRevenueChart(state.stats['dailyRevenue'] as Map<String, double>),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recentOrders,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const OrderManagementScreen(),
                              ),
                            ),
                          ),
                          child: Text(l10n.viewAll),
                        ),
                      ],
                    ),
                    _buildOrdersList(state.recentOrders),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AdminCubit>(),
                            child: const CategoryManagementScreen(),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.category),
                      label: Text(l10n.manageCategories),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AdminCubit>(),
                            child: const InventoryManagementScreen(),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.inventory),
                      label: Text(l10n.manageProducts),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, dynamic> stats) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: l10n.revenue,
            value: '${stats['totalRevenue'].toStringAsFixed(2)} EGP',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: l10n.orders,
            value: stats['orderCount'].toString(),
            icon: Icons.shopping_bag,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingToggle(BuildContext context, bool isFree) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: isFree ? Colors.green : Colors.blue),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.freeShipping,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isFree ? l10n.enabled : '${l10n.disabled} (90 EGP)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isFree,
            onChanged: (val) {
              context.read<AdminCubit>().updateShipping(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, double> dailyRevenue) {
    if (dailyRevenue.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No data yet')));

    final sortedKeys = dailyRevenue.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyRevenue[sortedKeys[i]]!));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.take(5).length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('Order #${order.id.substring(0, 8)}'),
          subtitle: Text(order.createdAt.toString().split('.')[0]),
          trailing: Text(
            '${order.totalAmount.toStringAsFixed(2)} EGP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
