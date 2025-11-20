import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/points_ledger_model.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load analytics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(adminProvider.error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => adminProvider.loadDashboardStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = adminProvider.dashboardStats;
          final transactions = adminProvider.recentTransactions;

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadDashboardStats(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  Text(
                    'Business Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _StatsCard(
                        title: 'Total Customers',
                        value: '${stats['total_customers'] ?? 0}',
                        icon: Icons.people,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _StatsCard(
                        title: 'Points Awarded\n(This Month)',
                        value: '${stats['points_awarded_month'] ?? 0}',
                        icon: Icons.stars,
                        color: Colors.green,
                      ),
                      _StatsCard(
                        title: 'Points Redeemed\n(This Month)',
                        value: '${stats['points_redeemed_month'] ?? 0}',
                        icon: Icons.trending_down,
                        color: Colors.orange,
                      ),
                      _StatsCard(
                        title: 'Active Coupons',
                        value: '${stats['active_coupons'] ?? 0}',
                        icon: Icons.receipt,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to full transactions view
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Full transaction history coming soon!')),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (transactions.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 48),
                              SizedBox(height: 8),
                              Text('No recent transactions'),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionCard(transaction: transaction);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final PointsLedgerModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isEarn = transaction.isEarn;
    final dateFormat = DateFormat('MMM dd • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEarn 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isEarn ? Icons.add : Icons.remove,
            color: isEarn 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        title: Text(
          isEarn ? 'Points Awarded' : 'Points Redeemed',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          dateFormat.format(transaction.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          '${isEarn ? '+' : ''}${transaction.change}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEarn 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}