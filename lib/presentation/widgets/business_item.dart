import 'dart:convert';
import 'package:flutter/material.dart';

import '../../data/models/business_dto.dart';
import '../../core/theme/app_colors.dart';

class BusinessItem extends StatelessWidget {
  final BusinessDto business;
  final VoidCallback onTap;

  const BusinessItem({
    super.key,
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (business.itemType == ItemType.header) {
      return _buildHeader(context);
    }
    
    return _buildBusinessItem(context);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.cardBackground,
      child: Text(
        business.displayName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBusinessItem(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.sekretessBlue.withAlpha((255 * 0.1).round()),
      highlightColor: AppColors.sekretessBlue.withAlpha((255 * 0.05).round()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: business.subscribed
              ? AppColors.sekretessBlue.withAlpha((255 * 0.1).round())
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: business.subscribed
                ? AppColors.sekretessBlue
                : AppColors.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildBusinessIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.subscribed ? 'Subscribed' : 'Not subscribed',
                    style: TextStyle(
                      fontSize: 14,
                      color: business.subscribed
                          ? AppColors.sekretessBlue
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessIcon() {
    if (business.icon != null && business.icon!.isNotEmpty) {
      try {
        // Decode base64 image
        final imageBytes = base64Decode(business.icon!);
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        );
      } catch (e) {
        // If decoding fails, show placeholder
      }
    }
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
      ),
      child: const Icon(
        Icons.business,
        color: AppColors.textSecondary,
        size: 30,
      ),
    );
  }
}
