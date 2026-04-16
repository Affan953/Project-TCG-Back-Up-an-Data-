import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class PokemonCard {
  final String id;
  final String name;
  final String supertype;
  final List<String> subtypes;
  final String hp;
  final List<String> types;
  final String evolvesFrom;
  final List<String> rules;
  final List<Attack> attacks;
  final List<String> weaknesses;
  final List<String> resistances;
  final List<String> retreatCost;
  final int convertedRetreatCost;
  final SetInfo set;
  final String number;
  final String artist;
  final String rarity;
  final String flavorText;
  final List<int> nationalPokedexNumbers;
  final Map<String, dynamic> images;
  final Map<String, dynamic> cardmarket;

  PokemonCard({
    required this.id,
    required this.name,
    required this.supertype,
    required this.subtypes,
    required this.hp,
    required this.types,
    required this.evolvesFrom,
    required this.rules,
    required this.attacks,
    required this.weaknesses,
    required this.resistances,
    required this.retreatCost,
    required this.convertedRetreatCost,
    required this.set,
    required this.number,
    required this.artist,
    required this.rarity,
    required this.flavorText,
    required this.nationalPokedexNumbers,
    required this.images,
    required this.cardmarket,
  });

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      supertype: json['supertype'] ?? '',
      subtypes: List<String>.from(json['subtypes'] ?? []),
      hp: json['hp'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      evolvesFrom: json['evolvesFrom'] ?? '',
      rules: List<String>.from(json['rules'] ?? []),
      attacks: (json['attacks'] as List<dynamic>?)
          ?.map((attack) => Attack.fromJson(attack))
          .toList() ?? [],
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      resistances: List<String>.from(json['resistances'] ?? []),
      retreatCost: List<String>.from(json['retreatCost'] ?? []),
      convertedRetreatCost: json['convertedRetreatCost'] ?? 0,
      set: SetInfo.fromJson(json['set'] ?? {}),
      number: json['number'] ?? '',
      artist: json['artist'] ?? '',
      rarity: json['rarity'] ?? '',
      flavorText: json['flavorText'] ?? '',
      nationalPokedexNumbers: List<int>.from(json['nationalPokedexNumbers'] ?? []),
      images: json['images'] ?? {},
      cardmarket: json['cardmarket'] ?? {},
    );
  }
}

class Attack {
  final String name;
  final List<String> cost;
  final int convertedEnergyCost;
  final String damage;
  final String text;

  Attack({
    required this.name,
    required this.cost,
    required this.convertedEnergyCost,
    required this.damage,
    required this.text,
  });

  factory Attack.fromJson(Map<String, dynamic> json) {
    return Attack(
      name: json['name'] ?? '',
      cost: List<String>.from(json['cost'] ?? []),
      convertedEnergyCost: json['convertedEnergyCost'] ?? 0,
      damage: json['damage'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class SetInfo {
  final String id;
  final String name;
  final String series;

  SetInfo({
    required this.id,
    required this.name,
    required this.series,
  });

  factory SetInfo.fromJson(Map<String, dynamic> json) {
    return SetInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      series: json['series'] ?? '',
    );
  }
}

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late Future<List<PokemonCard>> _futureCards;
  String _searchQuery = '';
  String? _setId;

  @override
  void initState() {
    super.initState();
    _setId = GoRouterState.of(context).uri.queryParameters['setId'];
    _futureCards = _fetchPokemonCards();
  }

  Future<List<PokemonCard>> _fetchPokemonCards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
    }

    String url = 'https://api-tcg-backend.vercel.app/api/pokemon/cards';
    if (_setId != null) {
      url += '?setId=$_setId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);

      List<dynamic> cardsData = [];

      if (decodedData is List) {
        cardsData = decodedData;
      } else if (decodedData is Map<String, dynamic>) {
        cardsData = decodedData['data'] ?? decodedData['cards'] ?? [];
      }

      return cardsData.map((item) => PokemonCard.fromJson(item as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesi telah habis (401). Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}.');
    }
  }

  List<PokemonCard> _filterCards(List<PokemonCard> cards) {
    if (_searchQuery.isEmpty) return cards;
    return cards.where((card) =>
      card.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      card.types.any((type) => type.toLowerCase().contains(_searchQuery.toLowerCase()))
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
              'Pokemon Cards',
              style: PokemonTextStyles.brandLogo(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _setId != null ? 'Kartu dari set terpilih' : 'Koleksi kartu Pokemon',
              style: PokemonTextStyles.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Home',
            onPressed: () => context.go(AppRoutes.homePath),
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            tooltip: 'Sets',
            onPressed: () => context.go(AppRoutes.setsPath),
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
                    hintText: 'Cari kartu Pokemon...',
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
              // Cards Grid
              Expanded(
                child: FutureBuilder<List<PokemonCard>>(
                  future: _futureCards,
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
                                  'Loading Pokemon cards...',
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
                                      _futureCards = _fetchPokemonCards();
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

                    final cards = _filterCards(snapshot.data ?? []);

                    if (cards.isEmpty) {
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
                                  'Tidak ada kartu ditemukan',
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

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return GestureDetector(
                          onTap: () {
                            // Show card detail dialog
                            _showCardDetailDialog(context, card);
                          },
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: card.images['small'] != null
                                    ? Image.network(
                                        card.images['small'],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white54,
                                            size: 60,
                                          ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 60,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  card.name,
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.hp.isNotEmpty ? 'HP: ${card.hp}' : card.supertype,
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                if (card.types.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: card.types.map((type) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: Text(
                                          type,
                                          style: PokemonTextStyles.inter(
                                            color: const Color(0xFFfbbf24),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                              ],
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

  void _showCardDetailDialog(BuildContext context, PokemonCard card) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (card.images['large'] != null)
                  Image.network(
                    card.images['large'],
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 100,
                      ),
                  ),
                const SizedBox(height: 16),
                Text(
                  card.name,
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${card.set.name} - ${card.number}',
                  style: PokemonTextStyles.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                if (card.hp.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'HP: ${card.hp}',
                    style: PokemonTextStyles.inter(
                      color: const Color(0xFFfbbf24),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (card.types.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: card.types.map((type) => Chip(
                      label: Text(
                        type,
                        style: PokemonTextStyles.inter(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: const Color(0xFFfbbf24),
                    )).toList(),
                  ),
                ],
                if (card.flavorText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    card.flavorText,
                    style: PokemonTextStyles.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add to favorites functionality
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${card.name} ditambahkan ke favorit!'),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Favorit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFfbbf24),
                        foregroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
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