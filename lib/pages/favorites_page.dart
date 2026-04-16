import 'dart:convert';
import 'package:flutter/material.dart';
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
      setState(() {
        _error = 'Gagal memuat favorit: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(int index) async {
    setState(() {
      _favorites.removeAt(index);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorites', json.encode(_favorites));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dihapus dari favorit'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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
              'My Favorites',
              style: PokemonTextStyles.brandLogo(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Koleksi kartu favorit Anda',
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
              Expanded(
                child: _isLoading
                  ? Center(
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
                                'Loading favorites...',
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
                    )
                  : _error.isNotEmpty
                    ? Center(
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
                                  _error,
                                  style: PokemonTextStyles.inter(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _loadFavorites,
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
                      )
                    : _favorites.isEmpty
                      ? Center(
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada kartu favorit',
                                    style: PokemonTextStyles.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tambahkan kartu favorit dari halaman kartu',
                                    style: PokemonTextStyles.inter(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () => context.go(AppRoutes.setsPath),
                                    icon: const Icon(Icons.list),
                                    label: const Text('Lihat Sets'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFfbbf24),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final favorite = _favorites[index];
                            return GestureDetector(
                              onTap: () {
                                // Show card detail dialog
                                _showCardDetailDialog(context, favorite, index);
                              },
                              child: GlassCard(
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: favorite['images']?['small'] != null
                                            ? Image.network(
                                                favorite['images']['small'],
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
                                          favorite['name'] ?? 'Unknown',
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
                                          favorite['hp']?.isNotEmpty == true
                                            ? 'HP: ${favorite['hp']}'
                                            : favorite['supertype'] ?? 'Card',
                                          style: PokemonTextStyles.inter(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        onPressed: () => _removeFromFavorites(index),
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Hapus dari favorit',
                                        iconSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  void _showCardDetailDialog(BuildContext context, Map<String, dynamic> card, int index) {
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
                if (card['images']?['large'] != null)
                  Image.network(
                    card['images']['large'],
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
                  card['name'] ?? 'Unknown',
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${card['set']?['name'] ?? 'Unknown Set'} - ${card['number'] ?? ''}',
                  style: PokemonTextStyles.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                if (card['hp']?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'HP: ${card['hp']}',
                    style: PokemonTextStyles.inter(
                      color: const Color(0xFFfbbf24),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (card['types'] != null && (card['types'] as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (card['types'] as List).map((type) => Chip(
                      label: Text(
                        type.toString(),
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
                if (card['flavorText']?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Text(
                    card['flavorText'],
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
                        _removeFromFavorites(index);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
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