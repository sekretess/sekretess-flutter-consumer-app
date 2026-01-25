import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/cryptographic_service.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? _username;
  bool _isLoading = true;
  bool _isUpdatingKeys = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final authRepository = getIt<AuthRepository>();
      final username = await authRepository.getUsername();
      if (mounted) {
        setState(() {
          _username = username ?? 'N/A';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = 'N/A';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authRepository = getIt<AuthRepository>();
      await authRepository.logout();
      // Navigation will be handled by MainPage listening to logoutStream
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final apiClient = getIt<ApiClient>();
        final success = await apiClient.deleteUser();
        
        if (mounted) {
          if (success) {
            final authRepository = getIt<AuthRepository>();
            await authRepository.clearUserData();
            // Navigation will be handled by MainPage listening to logoutStream
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete account. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleResetKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Encryption Keys'),
        content: const Text(
          'This will update your one-time encryption keys. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isUpdatingKeys = true;
      });

      try {
        final cryptographicService = getIt<CryptographicService>();
        await cryptographicService.updateOneTimeKeys();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Encryption keys updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update keys: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUpdatingKeys = false;
          });
        }
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Sekretess Consumer App\n\n'
          'Version 1.0.0\n\n'
          'Secure messaging application with end-to-end encryption.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Profile Avatar
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Username
                    Text(
                      _username ?? 'N/A',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Buttons
                    _buildActionButton(
                      icon: Icons.logout,
                      label: 'Logout',
                      onPressed: _handleLogout,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.autorenew,
                      label: 'Reset Encryption Keys',
                      onPressed: _isUpdatingKeys ? null : _handleResetKeys,
                      color: AppColors.white,
                      isLoading: _isUpdatingKeys,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.info_outline,
                      label: 'About',
                      onPressed: _showAboutDialog,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete account',
                      onPressed: _handleDeleteAccount,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
            child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          side: BorderSide(
            color: color.withAlpha((255 * 0.3).round()),
            width: 1,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
