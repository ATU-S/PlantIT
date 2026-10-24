import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/models/marketplace_model.dart';
import 'package:plantit/data/local/kerala_marketplace_catalog.dart';

class MarketplaceScreen extends StatefulWidget {
  final String? filterCropId;

  const MarketplaceScreen({super.key, this.filterCropId});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedDistrict = 'All Districts';
  VendorCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<NurseryVendor> vendors = KeralaMarketplaceCatalog.vendors;

    if (widget.filterCropId != null) {
      vendors = KeralaMarketplaceCatalog.getForCrop(widget.filterCropId!);
    }

    if (_selectedDistrict != 'All Districts') {
      vendors = vendors.where((v) => v.district == _selectedDistrict).toList();
    }
    if (_selectedCategory != null) {
      vendors = vendors.where((v) => v.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      vendors = vendors.where((v) =>
        v.name.toLowerCase().contains(q) ||
        v.locationArea.toLowerCase().contains(q) ||
        v.featuredOfferings.any((o) => o.title.toLowerCase().contains(q))
      ).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🏪', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              widget.filterCropId != null
                  ? 'Find Seedlings Nearby'
                  : 'Kerala Marketplace',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search nurseries, seeds, grow bags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // District chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                _districtChip('All Districts'),
                ...KeralaMarketplaceCatalog.allDistricts.map(_districtChip),
              ],
            ),
          ),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Row(
              children: [
                _categoryChip(null, '🌈 All'),
                _categoryChip(VendorCategory.seedlings, '🌱 Nurseries'),
                _categoryChip(VendorCategory.seedsAndSaplings, '🌾 Seeds'),
                _categoryChip(VendorCategory.growBagsAndSoil, '🪴 Soil & Bags'),
                _categoryChip(VendorCategory.organicCompost, '🪱 Compost'),
                _categoryChip(VendorCategory.krishibhavanGovt, '🏛️ Krishi Bhavan'),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Text(
                  '${vendors.length} ${vendors.length == 1 ? "vendor" : "vendors"} found',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Text('📍 Kerala, India',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Vendor list
          Expanded(
            child: vendors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌾', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 12),
                        Text('No vendors found for that filter',
                            style: GoogleFonts.outfit(
                                fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: vendors.length,
                    itemBuilder: (context, i) => _buildVendorCard(vendors[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _districtChip(String district) {
    final selected = _selectedDistrict == district;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(district),
        selected: selected,
        onSelected: (_) => setState(() => _selectedDistrict = district),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _categoryChip(VendorCategory? cat, String label) {
    final selected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = selected ? null : cat),
        selectedColor: const Color(0xFF00897B),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildVendorCard(NurseryVendor vendor, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(_vendorEmoji(vendor.category),
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(vendor.name,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                          if (vendor.isVerified)
                            const Tooltip(
                              message: 'Verified Vendor',
                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(vendor.categoryLabel,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('${vendor.locationArea}, ${vendor.district}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Rating
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  i < vendor.rating.floor() ? Icons.star : Icons.star_outline,
                  size: 14,
                  color: const Color(0xFFFFB300),
                )),
                const SizedBox(width: 6),
                Text('${vendor.rating} (${vendor.reviewsCount} reviews)',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                const Spacer(),
                Text('⏰ ${vendor.operationalHours}',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),

            const SizedBox(height: 12),

            // Featured offerings
            Text('Featured Offerings:',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            ...vendor.featuredOfferings.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.title,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ),
                  Text(item.priceEstimate,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Text(' ${item.unit}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            )),

            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                _actionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  color: Colors.green,
                  onTap: () => _launchUrl('tel:${vendor.phoneNumber}'),
                ),
                const SizedBox(width: 8),
                if (vendor.whatsappNumber != null)
                  _actionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _launchUrl(
                        'https://wa.me/91${vendor.whatsappNumber}?text=Hi! I found you on PlantIT app. I am interested in seedlings and plants.'),
                  ),
                const SizedBox(width: 8),
                _actionButton(
                  icon: Icons.map_outlined,
                  label: 'Directions',
                  color: Colors.blue,
                  onTap: () => _launchUrl(
                      'https://maps.google.com/?q=${Uri.encodeComponent(vendor.address)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15, color: color),
        label: Text(label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withAlpha(80)),
          padding: const EdgeInsets.symmetric(vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  String _vendorEmoji(VendorCategory cat) {
    switch (cat) {
      case VendorCategory.seedlings: return '🌱';
      case VendorCategory.seedsAndSaplings: return '🌾';
      case VendorCategory.growBagsAndSoil: return '🪴';
      case VendorCategory.organicCompost: return '🪱';
      case VendorCategory.krishibhavanGovt: return '🏛️';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }
}
