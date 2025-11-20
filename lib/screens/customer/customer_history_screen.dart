import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/rewards_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/points_ledger_model.dart';

class CustomerHistoryScreen extends StatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        rewardsProvider.loadUserHistory(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer2<RewardsProvider, AuthProvider>(
        builder: (context, rewardsProvider, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final history = rewardsProvider.userHistory;

          if (history.isEmpty && !rewardsProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No Transaction History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Your points and rewards history will appear here'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => rewardsProvider.loadUserHistory(user.id),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => rewardsProvider.loadUserHistory(user.id),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length + (rewardsProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == history.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final transaction = history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionCard(transaction: transaction),
                );
              },
            ),
          );
        },
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
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
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
          _getTransactionTitle(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.note != null) ...[
              Text(transaction.note!),
              const SizedBox(height: 4),
            ],
            Text(
              dateFormat.format(transaction.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isEarn ? '+' : ''}${transaction.change}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isEarn 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  String _getTransactionTitle() {
    if (transaction.isEarn) {
      return 'Points Earned';
    } else {
      return 'Reward Redeemed';
    }
  }
}