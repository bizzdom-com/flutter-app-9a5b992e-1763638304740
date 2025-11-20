import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../services/staff_service.dart';

enum ScanType { customer, coupon }

class StaffScannerScreen extends StatefulWidget {
  final ScanType scanType;
  
  const StaffScannerScreen({
    super.key,
    required this.scanType,
  });

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        _handleScan(scanData.code!);
      }
    });
  }

  Future<void> _handleScan(String qrCode) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    controller?.pauseCamera();

    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    
    try {
      if (widget.scanType == ScanType.customer) {
        await staffProvider.scanCustomerQR(qrCode);
        if (staffProvider.scannedCustomer != null && mounted) {
          _showCustomerDialog(staffProvider);
        } else if (staffProvider.error != null && mounted) {
          _showErrorAndResume(staffProvider.error!);
        }
      } else {
        await staffProvider.scanCouponQR(qrCode);
        if (staffProvider.scannedCoupon != null && mounted) {
          _showCouponDialog(staffProvider);
        } else if (staffProvider.error != null && mounted) {
          _showErrorAndResume(staffProvider.error!);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorAndResume(e.toString());
      }
    }

    // Only reset processing state and resume camera if no dialog was shown
    if (staffProvider.scannedCustomer == null && staffProvider.scannedCoupon == null) {
      setState(() => _isProcessing = false);
      controller?.resumeCamera();
    }
  }

  void _showErrorAndResume(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    setState(() => _isProcessing = false);
    controller?.resumeCamera();
  }

  void _showCustomerDialog(StaffProvider staffProvider) {
    final customer = staffProvider.scannedCustomer!;
    final balance = staffProvider.customerBalance!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15151E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
        title: Text(
          'Customer Found',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', customer.name ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildInfoRow('Email', customer.email ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildInfoRow('Balance', '${balance.pointsBalance} points'),
            const SizedBox(height: 20),
            Text(
              'Award points to this customer?',
              style: GoogleFonts.inter(
                color: const Color(0xFFA0A0B5),
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resumeCameraAfterDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA0A0B5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAwardPointsDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Award Points',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeCameraAfterDialog() {
    setState(() => _isProcessing = false);
    controller?.resumeCamera();
  }

  void _showAwardPointsDialog() {
    final List<int> quickAmounts = [50, 100, 250, 500];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15151E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
        title: Text(
          'Award Points',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select points to award:',
              style: GoogleFonts.inter(
                color: const Color(0xFFA0A0B5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: quickAmounts.map((amount) => 
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C2FF).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _awardPoints(amount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '$amount',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCustomAmountDialog();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00C2FF),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Custom Amount',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resumeCameraAfterDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA0A0B5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15151E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
        title: Text(
          'Custom Points',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Points to award',
            labelStyle: GoogleFonts.inter(
              color: const Color(0xFFA0A0B5),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C2FF), width: 2),
            ),
            fillColor: const Color(0xFF0A0A0F),
            filled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resumeCameraAfterDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA0A0B5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C2FF), Color(0xFF0080CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  Navigator.of(context).pop();
                  _awardPoints(amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Award',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _awardPoints(int points) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    try {
      final staffId = await StaffService.getStaffIdByUserId(authProvider.user!.id);
      if (staffId == null) {
        throw Exception('Staff record not found');
      }
      
      final success = await staffProvider.awardPoints(
        staffId: staffId,
        points: points,
        note: 'Points awarded by ${authProvider.user!.name}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Successfully awarded $points points!'
                  : staffProvider.error ?? 'Failed to award points',
            ),
            backgroundColor: success 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
        
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showCouponDialog(StaffProvider staffProvider) {
    final coupon = staffProvider.scannedCoupon!;
    final isActive = coupon.isActive;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15151E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
        title: Text(
          'Coupon Found',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Reward', coupon.reward?.name ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildInfoRow('Code', coupon.code),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA0A0B5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? const Color(0xFF4ADE80).withOpacity(0.15)
                        : const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive 
                          ? const Color(0xFF4ADE80).withOpacity(0.3)
                          : const Color(0xFFEF4444).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    coupon.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (coupon.reward?.description != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A35), width: 1),
                ),
                child: Text(
                  coupon.reward!.description!,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA0A0B5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resumeCameraAfterDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA0A0B5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          if (isActive)
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _redeemCoupon();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Redeem',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _redeemCoupon() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    try {
      final staffId = await StaffService.getStaffIdByUserId(authProvider.user!.id);
      if (staffId == null) {
        throw Exception('Staff record not found');
      }
      
      final success = await staffProvider.redeemCoupon(staffId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Coupon redeemed successfully!'
                  : staffProvider.error ?? 'Failed to redeem coupon',
            ),
            backgroundColor: success 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
        
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            color: const Color(0xFFA0A0B5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.scanType == ScanType.customer 
        ? 'Scan Customer QR' 
        : 'Scan Coupon QR';
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00C2FF)),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A35), width: 2),
              ),
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: const Color(0xFF00C2FF),
                    borderRadius: 16,
                    borderLength: 40,
                    borderWidth: 8,
                    cutOutSize: 280,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF15151E),
                border: Border(
                  top: BorderSide(color: Color(0xFF2A2A35), width: 1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA0A0B5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.scanType == ScanType.customer
                              ? [const Color(0xFF00C2FF), const Color(0xFF0080CC)]
                              : [const Color(0xFF4ADE80), const Color(0xFF22C55E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.scanType == ScanType.customer
                                ? const Color(0xFF00C2FF).withOpacity(0.3)
                                : const Color(0xFF4ADE80).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.scanType == ScanType.customer 
                            ? Icons.qr_code_scanner 
                            : Icons.redeem,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.scanType == ScanType.customer
                          ? 'Point the camera at customer QR code'
                          : 'Point the camera at coupon QR code',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA0A0B5),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}