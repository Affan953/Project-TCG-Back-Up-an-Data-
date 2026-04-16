import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({super.key});

  @override
  State<HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<HomeDashboardContent> {
  late Future<List<PokemonSet>> _futureSets;
  String _searchQuery = '';

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
    } else if (response.statusCode == 401) {
      throw Exception('Sesi telah habis (401). Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}.');
    }
  }

  List<PokemonSet> _filterSets(List<PokemonSet> sets) {
    if (_searchQuery.isEmpty) return sets;
    return sets.where((set) =>
      set.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      set.series.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Trainer',
              style: PokemonTextStyles.brandLogo(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sikat semua set Pokemon terbaru hari ini.',
              style: PokemonTextStyles.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => context.go(AppRoutes.settingsPath),
          ),
        ],
      ),
      body: PokemonBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 104),
              // Search Bar
              GlassCard(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari set Pokemon...',
                    hintStyle: PokemonTextStyles.inter(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.setsPath),
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.list,
                                color: Color(0xFFfbbf24),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Browse Sets',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.favoritesPath),
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Favorites',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.topupPath),
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF4CAF50),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Top Up',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sets List
              Expanded(
                child: FutureBuilder<List<PokemonSet>>(
                  future: _futureSets,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Loading Pokemon sets...',
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const CircularProgressIndicator(
                                  color: Color(0xFFfbbf24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade400,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Oops! Something went wrong',
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _futureSets = _fetchPokemonSets();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFfbbf24),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Coba Lagi',
                                    style: PokemonTextStyles.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final sets = _filterSets(snapshot.data ?? []);

                    if (sets.isEmpty) {
                      return Center(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada set ditemukan',
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: sets.length,
                      itemBuilder: (context, index) {
                        final set = sets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: ListTile(
                              leading: set.images['symbol'] != null
                                ? Image.network(
                                    set.images['symbol'],
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                              title: Text(
                                set.name,
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    set.series,
                                    style: PokemonTextStyles.inter(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${set.total} kartu • ${set.ptcgoCode}',
                                    style: PokemonTextStyles.inter(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.6),
                                size: 16,
                              ),
                              onTap: () {
                                // Navigate to cards page with set ID
                                context.go('${AppRoutes.cardsPath}?setId=${set.id}');
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}