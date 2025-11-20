import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/points_ledger_model.dart';

class StaffHistoryScreen extends StatefulWidget {
  const StaffHistoryScreen({super.key});

  @override
  State<StaffHistoryScreen> createState() => _StaffHistoryScreenState();
}

class _StaffHistoryScreenState extends State<StaffHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final staffProvider = Provider.of<StaffProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        staffProvider.loadStaffHistory(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StaffProvider, AuthProvider>(
      builder: (context, staffProvider, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        final history = staffProvider.staffHistory;

        if (history.isEmpty && !staffProvider.isLoading) {
          return Container(
            color: const Color(0xFF0A0A0F),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15151E),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFF2A2A35), width: 2),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 48,
                      color: Color(0xFFA0A0B5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Transaction History',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your awarded points will appear here',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B5),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
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
                    child: ElevatedButton(
                      onPressed: () => staffProvider.loadStaffHistory(user.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Refresh',
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
          );
        }

        return Container(
          color: const Color(0xFF0A0A0F),
          child: RefreshIndicator(
            onRefresh: () => staffProvider.loadStaffHistory(user.id),
            backgroundColor: const Color(0xFF15151E),
            color: const Color(0xFF00C2FF),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length + (staffProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == history.length) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                      ),
                    ),
                  );
                }

                final transaction = history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StaffTransactionCard(transaction: transaction),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class StaffTransactionCard extends StatelessWidget {
  final PointsLedgerModel transaction;

  const StaffTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2FF).withOpacity(0.05),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ADE80).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_circle,
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
                  'Points Awarded',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (transaction.note != null) ...[
                  Text(
                    transaction.note!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA0A0B5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
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
              color: const Color(0xFF4ADE80).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4ADE80).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '+${transaction.change}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4ADE80),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}