import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../models/reward_model.dart';
import '../../theme/app_theme.dart';

class AdminRewardsScreen extends StatefulWidget {
  const AdminRewardsScreen({super.key});

  @override
  State<AdminRewardsScreen> createState() => _AdminRewardsScreenState();
}

class _AdminRewardsScreenState extends State<AdminRewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadRewards();
    });
  }

  void _showAddRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditRewardDialog(),
    );
  }

  void _showEditRewardDialog(RewardModel reward) {
    showDialog(
      context: context,
      builder: (context) => AddEditRewardDialog(reward: reward),
    );
  }

  void _confirmDeleteReward(RewardModel reward) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: AppTheme.neuromorphicDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: Color(0xFFEF4444),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Delete Reward?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Are you sure you want to delete "${reward.name}"? This action cannot be undone.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                            final success = await adminProvider.deleteReward(reward.id);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success 
                                        ? 'Reward deleted successfully' 
                                        : adminProvider.error ?? 'Failed to delete reward',
                                    style: GoogleFonts.inter(color: Colors.white),
                                  ),
                                  backgroundColor: success 
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'DELETE',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF101020),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF60A5FA),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MANAGE REWARDS',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create and manage loyalty rewards',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content Area
              Expanded(
                child: Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (adminProvider.isLoading && adminProvider.rewards.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60A5FA)),
                        ),
                      );
                    }

                    if (adminProvider.error != null && adminProvider.rewards.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(32),
                          decoration: AppTheme.neuromorphicDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFEF4444).withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Failed to Load Rewards',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                adminProvider.error!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF60A5FA).withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => adminProvider.loadRewards(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'RETRY',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final rewards = adminProvider.rewards;

                    if (rewards.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(32),
                          decoration: AppTheme.neuromorphicDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF60A5FA).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF60A5FA).withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.card_giftcard_outlined,
                                  size: 40,
                                  color: Color(0xFF60A5FA),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Rewards Yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Create your first reward to get started with your loyalty program',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => adminProvider.loadRewards(),
                      color: const Color(0xFF60A5FA),
                      backgroundColor: const Color(0xFF15151E),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: rewards.length,
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          return _ModernRewardCard(
                            reward: reward,
                            onEdit: () => _showEditRewardDialog(reward),
                            onDelete: () => _confirmDeleteReward(reward),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddRewardDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _ModernRewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModernRewardCard({
    required this.reward,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.neuromorphicDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Reward Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Reward Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (reward.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      reward.description!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF60A5FA).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${reward.costPoints} points',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Column(
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
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

class AddEditRewardDialog extends StatefulWidget {
  final RewardModel? reward;

  const AddEditRewardDialog({super.key, this.reward});

  bool get isEditing => reward != null;

  @override
  State<AddEditRewardDialog> createState() => _AddEditRewardDialogState();
}

class _AddEditRewardDialogState extends State<AddEditRewardDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reward?.name ?? '');
    _descriptionController = TextEditingController(text: widget.reward?.description ?? '');
    _pointsController = TextEditingController(text: widget.reward?.costPoints.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.reward?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveReward() async {
    if (!_formKey.currentState!.validate()) return;

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final points = int.parse(_pointsController.text.trim());
    final imageUrl = _imageUrlController.text.trim().isEmpty 
        ? null 
        : _imageUrlController.text.trim();

    bool success;
    if (widget.isEditing) {
      success = await adminProvider.updateReward(
        id: widget.reward!.id,
        name: name,
        description: description,
        costPoints: points,
        imageUrl: imageUrl,
      );
    } else {
      success = await adminProvider.createReward(
        name: name,
        description: description,
        costPoints: points,
        imageUrl: imageUrl,
      );
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? 'Reward updated successfully' 
                  : 'Reward created successfully',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.error ?? 'Failed to save reward'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: AppTheme.neuromorphicDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF60A5FA).withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Color(0xFF60A5FA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.isEditing ? 'Edit Reward' : 'Add New Reward',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Reward Name
                      Container(
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: TextFormField(
                          controller: _nameController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Reward Name',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                            ),
                            prefixIcon: const Icon(
                              Icons.edit,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a reward name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Container(
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: TextFormField(
                          controller: _descriptionController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                            ),
                            prefixIcon: const Icon(
                              Icons.description,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Points Cost
                      Container(
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: TextFormField(
                          controller: _pointsController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Points Cost',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                            ),
                            prefixIcon: const Icon(
                              Icons.stars,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter points cost';
                            }
                            final points = int.tryParse(value!);
                            if (points == null || points <= 0) {
                              return 'Please enter a valid points amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image URL (optional)
                      Container(
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: TextFormField(
                          controller: _imageUrlController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Image URL (optional)',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                            ),
                            prefixIcon: const Icon(
                              Icons.image,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: AppTheme.neuromorphicDecoration(),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<AdminProvider>(
                        builder: (context, adminProvider, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF60A5FA).withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: adminProvider.isLoading ? null : _saveReward,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: adminProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      widget.isEditing ? 'UPDATE' : 'CREATE',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}