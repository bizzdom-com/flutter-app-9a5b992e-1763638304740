import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../models/points_ledger_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const CustomerHomeScreen({super.key, this.onNavigateToTab});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
      
      authProvider.refreshBalance();
      if (authProvider.user != null) {
        rewardsProvider.loadUserHistory(authProvider.user!.id);
      }
    });
  }

  void _showQRCode(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF15151E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'My QR Code',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Show this to staff to earn points',
                style: GoogleFonts.inter(
                  color: const Color(0xFFA0A0B5),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00C2FF).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C2FF).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: 'customer:$userId',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: const Color(0xFF15151E),
          color: const Color(0xFF00C2FF),
          onRefresh: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
            
            await authProvider.refreshBalance();
            if (authProvider.user != null) {
              await rewardsProvider.loadUserHistory(authProvider.user!.id);
            }
          },
          child: Consumer2<AuthProvider, RewardsProvider>(
            builder: (context, authProvider, rewardsProvider, child) {
              final user = authProvider.user;
              final balance = authProvider.customerBalance;
              
              if (user == null) {
                return const Center(child: Text('User not found'));
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user.name ?? 'Customer'}!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF15151E), Color(0xFF1A1A28)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2A2A35), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C2FF).withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00C2FF).withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Points Balance',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFA0A0B5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    balance?.pointsBalance.toString() ?? '0',
                                    style: GoogleFonts.poppins(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00C2FF),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00C2FF).withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: -2,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showQRCode(context, user.id.toString()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.qr_code_2, color: Colors.white),
                                    label: Text(
                                      'Show QR Code',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context: context,
                            icon: Icons.card_giftcard,
                            title: 'Redeem\nRewards',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3D7F), Color(0xFFE91E63)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => widget.onNavigateToTab?.call(1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            context: context,
                            icon: Icons.receipt_long,
                            title: 'My\nCoupons',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => widget.onNavigateToTab?.call(2),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onNavigateToTab?.call(3); // Navigate to History tab
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF00C2FF),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    _buildRecentActivity(context, rewardsProvider.userHistory),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<PointsLedgerModel> history) {
    final recentHistory = history.take(3).toList(); // Show last 3 transactions
    
    if (recentHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF15151E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A35), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0F),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF2A2A35), width: 2),
              ),
              child: const Icon(
                Icons.info_outline,
                size: 32,
                color: Color(0xFFA0A0B5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent activity',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Earn points by showing your QR code to staff',
              style: GoogleFonts.inter(
                color: const Color(0xFFA0A0B5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentHistory.map((transaction) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RecentTransactionCard(transaction: transaction),
        ),
      ).toList(),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  final PointsLedgerModel transaction;

  const _RecentTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isEarn = transaction.isEarn;
    final dateFormat = DateFormat('MMM dd • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35), width: 1),
        boxShadow: [
          BoxShadow(
            color: isEarn 
                ? const Color(0xFF4ADE80).withOpacity(0.05)
                : const Color(0xFFFF3D7F).withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEarn 
                    ? [const Color(0xFF4ADE80), const Color(0xFF22C55E)]
                    : [const Color(0xFFFF3D7F), const Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isEarn 
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFFF3D7F)).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(
              isEarn ? Icons.add_circle : Icons.remove_circle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(transaction.createdAt),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF5A5A70),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isEarn 
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFFF3D7F)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isEarn 
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFF3D7F)).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${isEarn ? '+' : ''}${transaction.change}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isEarn 
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFF3D7F),
                fontSize: 14,
              ),
            ),
          ),
        ],
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