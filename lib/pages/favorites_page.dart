import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      if (favoritesJson != null) {
        final List<dynamic> favoritesData = json.decode(favoritesJson);
        _favorites = favoritesData.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      _error = 'Gagal memuat favorit: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(int index) async {
    final removedCard = _favorites[index];
    setState(() => _favorites.removeAt(index));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorites', json.encode(_favorites));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${removedCard['name']} removed from favorites'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      _loadFavorites(); // Revert on failure
    }
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
          'HALL OF FAME',
          style: PokemonTextStyles.brandLogo(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.go(AppRoutes.homePath),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.redAccent),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PokemonBackground(
        child: Column(
          children: [
            const SizedBox(height: 100),
            _buildFavoritesHeader(),
            Expanded(
              child: _isLoading 
                ? _buildLoadingState() 
                : _favorites.isEmpty 
                  ? _buildEmptyState() 
                  : _buildFavoritesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MY FAVORITES', style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text('${_favorites.length} PRIZED CARDS', style: PokemonTextStyles.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildFavoritesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.68,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) => _buildFavoriteCard(_favorites[index], index),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> card, int index) {
    return GestureDetector(
      onTap: () => _showCardDetails(card, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: -2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  card['images']?['small'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.style_outlined, color: Colors.white10, size: 50),
                ),
              ),
              
              // Holographic Shimmer
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.45, 0.5, 0.55],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 2.5.seconds, color: Colors.white.withOpacity(0.12)),
              ),

              // Favorite Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                ),
              ),

              // Name Info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.85)]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(card['name'] ?? 'Unknown', style: PokemonTextStyles.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900), maxLines: 1),
                      Text(card['supertype']?.toUpperCase() ?? 'CARD', style: PokemonTextStyles.inter(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index % 10 * 60).ms).scale(begin: const Offset(0.95, 0.95));
  }

  void _showCardDetails(Map<String, dynamic> card, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: GlassCard(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(card['images']?['large'] ?? '', height: 380, fit: BoxFit.contain),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutQuart),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(card['name'] ?? 'Unknown', style: PokemonTextStyles.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                      Text(card['set']?['name'] ?? 'Expansion Unknown', style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 14)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDetailCol('TYPE', card['types']?.first ?? 'N/A'),
                          _buildDetailCol('RARITY', card['rarity'] ?? 'Common'),
                          _buildDetailCol('HP', card['hp'] ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _removeFromFavorites(index);
                              },
                              icon: const Icon(Icons.heart_broken_rounded, size: 18),
                              label: const Text('REMOVE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.05),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('CLOSE'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCol(String label, String val) {
    return Column(
      children: [
        Text(label, style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(val, style: PokemonTextStyles.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('INVOKING FAVORITES...', style: PokemonTextStyles.inter(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border_rounded, color: Colors.white12, size: 80),
          const SizedBox(height: 20),
          Text('EMPTY HALL OF FAME', style: PokemonTextStyles.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          Text('Your most prized cards will appear here.', style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.myCardsPath),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('EXPLORE COLLECTION'),
          ),
        ],
      ),
    );
  }
}