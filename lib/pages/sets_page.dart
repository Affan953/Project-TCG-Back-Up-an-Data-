import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_pokemon/providers/card_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class PokemonSet {
  final String id;
  final String name;
  final String series;
  final int printedTotal;
  final int total;
  final String ptcgoCode;
  final String releaseDate;
  final String updatedAt;
  final Map<String, dynamic> images;

  PokemonSet({
    required this.id,
    required this.name,
    required this.series,
    required this.printedTotal,
    required this.total,
    required this.ptcgoCode,
    required this.releaseDate,
    required this.updatedAt,
    required this.images,
  });

  factory PokemonSet.fromJson(Map<String, dynamic> json) {
    return PokemonSet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      series: json['series'] ?? '',
      printedTotal: json['printedTotal'] ?? 0,
      total: json['total'] ?? 0,
      ptcgoCode: json['ptcgoCode'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      images: json['images'] ?? {},
    );
  }
}

class SetsPage extends StatefulWidget {
  const SetsPage({super.key});

  @override
  State<SetsPage> createState() => _SetsPageState();
}

class _SetsPageState extends State<SetsPage> {
  late Future<List<PokemonSet>> _futureSets;
  String _searchQuery = '';
  String _selectedSeries = 'All';

  @override
  void initState() {
    super.initState();
    _futureSets = _fetchPokemonSets();
  }

  Future<List<PokemonSet>> _fetchPokemonSets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
    }

    final response = await http.get(
      Uri.parse('https://api-tcg-backend.vercel.app/api/pokemon/sets'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      List<dynamic> setsData = [];
      if (decodedData is List) {
        setsData = decodedData;
      } else if (decodedData is Map<String, dynamic>) {
        setsData = decodedData['data'] ?? decodedData['sets'] ?? [];
      }
      return setsData.map((item) => PokemonSet.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data dari Professor Oak.');
    }
  }

  List<PokemonSet> _filterSets(List<PokemonSet> sets) {
    var filtered = sets;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((set) =>
          set.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          set.series.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedSeries != 'All') {
      filtered = filtered.where((set) => set.series == _selectedSeries).toList();
    }
    return filtered;
  }

  List<String> _getSeriesList(List<PokemonSet> sets) {
    final series = {'All'};
    for (var s in sets) {
      series.add(s.series);
    }
    return series.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'EXPANSIONS',
          style: PokemonTextStyles.brandLogo(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.go(AppRoutes.homePath),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_rounded, color: Color(0xFFfbbf24)),
            onPressed: () => context.go(AppRoutes.myCardsPath),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PokemonBackground(
        child: FutureBuilder<List<PokemonSet>>(
          future: _futureSets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final allSets = snapshot.data ?? [];
            final filteredSets = _filterSets(allSets);
            final series = _getSeriesList(allSets);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                
                // Hero Cinematic Banner
                SliverToBoxAdapter(
                  child: _buildHeroBanner(filteredSets.isNotEmpty ? filteredSets.first : null),
                ),

                // Search & Filter Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        _buildSeriesFilters(series),
                        const SizedBox(height: 10),
                        Text(
                          '${filteredSets.length} EXPANSIONS FOUND',
                          style: PokemonTextStyles.inter(
                            color: Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid of Expansion Packs
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildSetCard(filteredSets[index], index),
                      childCount: filteredSets.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroBanner(PokemonSet? featuredSet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      width: double.infinity,
      child: GlassCard(
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Icon(Icons.stars_rounded, size: 200, color: Colors.white.withOpacity(0.03)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfbbf24).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'FEATURED EXPANSION',
                            style: PokemonTextStyles.inter(color: const Color(0xFFfbbf24), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          featuredSet?.name ?? 'Discover New Sets',
                          style: PokemonTextStyles.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          featuredSet != null ? 'Explore the ${featuredSet.series} collection' : 'Catch them all today',
                          style: PokemonTextStyles.inter(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (featuredSet?.images['logo'] != null)
                    Image.network(featuredSet!.images['logo'], width: 100, fit: BoxFit.contain)
                  else
                    const Icon(Icons.style_rounded, size: 80, color: Colors.white10),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: PokemonTextStyles.inter(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for expansions...',
          hintStyle: PokemonTextStyles.inter(color: Colors.white24),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSeriesFilters(List<String> series) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: series.map((s) {
          final isSelected = _selectedSeries == s;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedSeries = s),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: const Color(0xFFfbbf24),
              labelStyle: PokemonTextStyles.inter(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSetCard(PokemonSet set, int index) {
    return GestureDetector(
      onTap: () => _showExpansionDetails(set),
      child: GlassCard(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Hero(
                  tag: 'logo_${set.id}',
                  child: set.images['logo'] != null
                      ? Image.network(set.images['logo'], fit: BoxFit.contain)
                      : const Icon(Icons.style_outlined, size: 50, color: Colors.white10),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set.name,
                      style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      set.series.toUpperCase(),
                      style: PokemonTextStyles.inter(color: const Color(0xFFfbbf24), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${set.total} Cards', style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 10)),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index % 6 * 100).ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  void _showExpansionDetails(PokemonSet set) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExpansionSheet(set: set),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFfbbf24)),
          const SizedBox(height: 20),
          Text('CONSULTING PROFESSOR OAK...', style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              Text('DATA LINK FAILURE', style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center, style: PokemonTextStyles.inter(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _futureSets = _fetchPokemonSets()),
                child: const Text('RETRY LINK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpansionSheet extends StatelessWidget {
  final PokemonSet set;
  const _ExpansionSheet({required this.set});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Hero(
                    tag: 'logo_${set.id}',
                    child: set.images['logo'] != null
                        ? Image.network(set.images['logo'], height: 120, fit: BoxFit.contain)
                        : const Icon(Icons.style_outlined, size: 80, color: Colors.white10),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  set.name.toUpperCase(),
                  style: PokemonTextStyles.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                Text(
                  '${set.series} Series • Released ${set.releaseDate}',
                  style: PokemonTextStyles.inter(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildStatDetail('TOTAL CARDS', set.total.toString(), Icons.style_rounded),
                    const SizedBox(width: 16),
                    _buildStatDetail('PTCGO CODE', set.ptcgoCode, Icons.qr_code_rounded),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('${AppRoutes.cardsPath}?setId=${set.id}'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('VIEW CARD LIST', style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _buyPack(context, set),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFfbbf24),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('BUY PACK', style: PokemonTextStyles.inter(color: Colors.black, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFfbbf24), size: 18),
            const SizedBox(height: 12),
            Text(label, style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text(value, style: PokemonTextStyles.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  void _buyPack(BuildContext context, PokemonSet set) async {
    Navigator.pop(context); // Close sheet
    final success = await context.read<CardProvider>().buyPack(set.id);
    if (success) {
      final purchaseResult = context.read<CardProvider>().lastPurchaseResult;
      if (purchaseResult != null) {
        context.goNamed(AppRoutes.purchaseResultName, extra: purchaseResult);
      }
    } else {
      final error = context.read<CardProvider>().errorMessage ?? 'Failed to buy pack';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    }
  }
}