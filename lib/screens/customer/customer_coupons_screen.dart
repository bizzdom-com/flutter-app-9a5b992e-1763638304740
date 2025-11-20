import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/rewards_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/coupon_model.dart';

class CustomerCouponsScreen extends StatefulWidget {
  const CustomerCouponsScreen({super.key});

  @override
  State<CustomerCouponsScreen> createState() => _CustomerCouponsScreenState();
}

class _CustomerCouponsScreenState extends State<CustomerCouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        rewardsProvider.loadUserCoupons(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCouponQRCode(BuildContext context, CouponModel coupon) {
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
                    colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
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
                'Coupon QR Code',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                coupon.reward?.name ?? 'Reward',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Show this to staff to redeem your reward',
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
                    color: const Color(0xFF4ADE80).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ADE80).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: 'coupon:${coupon.code}',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A35), width: 1),
                ),
                child: Text(
                  'Code: ${coupon.code}',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF4ADE80),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
      appBar: AppBar(
        title: Text(
          'My Coupons',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00C2FF)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00C2FF),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: const Color(0xFF00C2FF),
          unselectedLabelColor: const Color(0xFFA0A0B5),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Used'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: Consumer2<RewardsProvider, AuthProvider>(
        builder: (context, rewardsProvider, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _CouponsList(
                coupons: rewardsProvider.activeCoupons,
                isLoading: rewardsProvider.isLoading,
                onRefresh: () => rewardsProvider.loadUserCoupons(user.id),
                onCouponTap: (coupon) => _showCouponQRCode(context, coupon),
                emptyMessage: 'No active coupons',
                emptyDescription: 'Redeem rewards to get coupons',
              ),
              _CouponsList(
                coupons: rewardsProvider.usedCoupons,
                isLoading: rewardsProvider.isLoading,
                onRefresh: () => rewardsProvider.loadUserCoupons(user.id),
                onCouponTap: null, // Can't show QR for used coupons
                emptyMessage: 'No used coupons',
                emptyDescription: 'Redeemed coupons will appear here',
              ),
              _CouponsList(
                coupons: rewardsProvider.expiredCoupons,
                isLoading: rewardsProvider.isLoading,
                onRefresh: () => rewardsProvider.loadUserCoupons(user.id),
                onCouponTap: null, // Can't show QR for expired coupons
                emptyMessage: 'No expired coupons',
                emptyDescription: 'Expired coupons will appear here',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CouponsList extends StatelessWidget {
  final List<CouponModel> coupons;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final void Function(CouponModel)? onCouponTap;
  final String emptyMessage;
  final String emptyDescription;

  const _CouponsList({
    required this.coupons,
    required this.isLoading,
    required this.onRefresh,
    required this.onCouponTap,
    required this.emptyMessage,
    required this.emptyDescription,
  });

  @override
  Widget build(BuildContext context) {
    if (coupons.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF15151E),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF2A2A35), width: 2),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 48,
                color: Color(0xFFA0A0B5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptyDescription,
              style: GoogleFonts.inter(
                color: const Color(0xFFA0A0B5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
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
                onPressed: onRefresh,
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
      );
    }

    return RefreshIndicator(
      backgroundColor: const Color(0xFF15151E),
      color: const Color(0xFF00C2FF),
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == coupons.length) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                ),
              ),
            );
          }

          final coupon = coupons[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CouponCard(
              coupon: coupon,
              onTap: onCouponTap != null ? () => onCouponTap!(coupon) : null,
            ),
          );
        },
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback? onTap;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final isActive = coupon.isActive;
    final isUsed = coupon.isUsed;

    Color statusColor;
    IconData statusIcon;
    if (isActive) {
      statusColor = const Color(0xFF4ADE80);
      statusIcon = Icons.check_circle;
    } else if (isUsed) {
      statusColor = const Color(0xFF00C2FF);
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive 
              ? statusColor.withOpacity(0.3)
              : const Color(0xFF2A2A35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive 
                ? statusColor.withOpacity(0.1)
                : Colors.transparent,
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isActive
                            ? [const Color(0xFF4ADE80), const Color(0xFF22C55E)]
                            : isUsed
                                ? [const Color(0xFF00C2FF), const Color(0xFF0080CC)]
                                : [const Color(0xFF5A5A70), const Color(0xFF404040)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(isActive ? 0.3 : 0.1),
                          blurRadius: 15,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.reward?.name ?? 'Reward',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (coupon.reward?.description != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            coupon.reward!.description!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFA0A0B5),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0F),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2A2A35), width: 1),
                          ),
                          child: Text(
                            'Code: ${coupon.code}',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF4ADE80),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${dateFormat.format(coupon.createdAt)}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF5A5A70),
                            fontSize: 12,
                          ),
                        ),
                        if (coupon.redeemedAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Used: ${dateFormat.format(coupon.redeemedAt!)}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF5A5A70),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      coupon.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isActive && onTap != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C2FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00C2FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        size: 16,
                        color: Color(0xFF00C2FF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to show QR code',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00C2FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}