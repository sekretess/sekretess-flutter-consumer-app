import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/business_dto.dart';
import '../widgets/business_item.dart';
import '../widgets/business_info_bottom_sheet.dart';
import '../providers/business_provider.dart';
import '../../core/theme/app_colors.dart';

class BusinessesPage extends ConsumerStatefulWidget {
  const BusinessesPage({super.key});

  @override
  ConsumerState<BusinessesPage> createState() => _BusinessesPageState();
}

class _BusinessesPageState extends ConsumerState<BusinessesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showBusinessInfo(BusinessDto business) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessInfoBottomSheet(
        business: business,
        onSubscriptionChanged: () {
          // Refresh the businesses list
          ref.invalidate(businessesProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(filteredBusinessesProvider(_searchQuery));

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.3).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search businesses...',
                prefixIcon: const Icon(Icons.search, color: AppColors.white),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.white),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                hintStyle: const TextStyle(color: AppColors.textSecondary),
              ),
              style: const TextStyle(color: AppColors.white),
            ),
          ),

          // Businesses List
          Expanded(
            child: businesses.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(businessesProvider);
                    },
                    color: AppColors.sekretessBlue,
                    child: ListView.builder(
                      itemCount: businesses.length,
                      itemBuilder: (context, index) {
                        final business = businesses[index];
                        // Skip header items in tap handling
                        if (business.itemType == ItemType.header) {
                          return BusinessItem(
                            business: business,
                            onTap: () {},
                          );
                        }
                        return BusinessItem(
                          business: business,
                          onTap: () => _showBusinessInfo(business),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'No businesses found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
