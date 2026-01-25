import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TrustedSenderItem extends StatelessWidget {
  final String businessName;
  final VoidCallback? onTap;
  final bool isAddNew;

  const TrustedSenderItem({
    super.key,
    required this.businessName,
    this.onTap,
    this.isAddNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAddNew 
                    ? AppColors.sekretessBlue.withAlpha((255 * 0.1).round())
                    : AppColors.cardBackground,
                border: Border.all(
                  color: isAddNew 
                      ? AppColors.sekretessBlue
                      : AppColors.dividerColor,
                  width: 2,
                ),
              ),
              child: isAddNew
                  ? const Icon(
                      Icons.add,
                      color: AppColors.sekretessBlue,
                      size: 30,
                    )
                  : _buildBusinessImage(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 70,
              child: Text(
                businessName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessImage() {
    // TODO: Implement image loading from local storage using path_provider
    // For now, just show placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
      ),
      child: Center(
        child: Text(
          businessName.isNotEmpty ? businessName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
