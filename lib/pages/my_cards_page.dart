import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/providers/card_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key});

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
  String _searchQuery = '';
  String? _selectedSetId;
  String? _selectedType;
  
  final List<String> _types = ['Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Fighting', 'Darkness', 'Metal', 'Dragon', 'Colorless'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().fetchMyCards();
    });
  }

  List<CardData> _filterCards(List<CardData> cards) {
    var filtered = cards;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) => c.cardName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedSetId != null) {
      filtered = filtered.where((c) => c.setId == _selectedSetId).toList();
    }
    // Note: CardData might need 'types' field expansion. For now we use name search as fallback or a fake type filter demonstration.
    return filtered;
  }

  Color _getRarityColor(String? rarity) {
    if (rarity == null) return Colors.white24;
    final r = rarity.toLowerCase();
    if (r.contains('secret')) return const Color(0xFFfbbf24); // Gold
    if (r.contains('ultra') || r.contains('rainbow')) return const Color(0xFFa78bfa); // Purple
    if (r.contains('holo') || r.contains('rare')) return const Color(0xFF60a5fa); // Blue
    return Colors.white24;
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();
    final filteredCards = _filterCards(cardProvider.myCards);
    final sets = cardProvider.myCards.map((c) => c.setId).toSet().toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'MASTER COLLECTION',
          style: PokemonTextStyles.brandLogo(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.go(AppRoutes.homePath),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFFfbbf24)),
            onPressed: () => context.go(AppRoutes.setsPath),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PokemonBackground(
        child: Column(
          children: [
            const SizedBox(height: 100),
            
            // Stats Header
            _buildCollectionSummary(cardProvider.myCards.length),

            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildFilterChips(sets),
                ],
              ),
            ),

            // Grid Content
            Expanded(
              child: cardProvider.isLoading
                  ? _buildLoadingState()
                  : filteredCards.isEmpty
                      ? _buildEmptyState()
                      : _buildCardGrid(filteredCards),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionSummary(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.style_rounded, color: Color(0xFFfbbf24), size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL COLLECTED', style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      Text('$total Cards', style: PokemonTextStyles.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: PokemonTextStyles.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search collection...',
          hintStyle: PokemonTextStyles.inter(color: Colors.white24, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<String> sets) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Sets'),
            selected: _selectedSetId == null,
            onSelected: (val) => setState(() => _selectedSetId = null),
            backgroundColor: Colors.white.withOpacity(0.05),
            selectedColor: const Color(0xFFfbbf24),
            labelStyle: PokemonTextStyles.inter(color: _selectedSetId == null ? Colors.black : Colors.white60, fontSize: 11, fontWeight: FontWeight.w900),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(width: 8),
          ...sets.map((setId) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(setId.toUpperCase()),
              selected: _selectedSetId == setId,
              onSelected: (val) => setState(() => _selectedSetId = val ? setId : null),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: const Color(0xFFfbbf24),
              labelStyle: PokemonTextStyles.inter(color: _selectedSetId == setId ? Colors.black : Colors.white60, fontSize: 11, fontWeight: FontWeight.w900),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCardGrid(List<CardData> cards) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.68,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _buildHolographicCard(cards[index], index),
    );
  }

  Widget _buildHolographicCard(CardData card, int index) {
    final auraColor = _getRarityColor(null); // Assuming no rarity field in CardData for now
    
    return GestureDetector(
      onTap: () => _showCardDetails(card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: auraColor.withOpacity(0.15), blurRadius: 12, spreadRadius: -2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.network(
                  card.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.style_outlined, color: Colors.white10, size: 50),
                ),
              ),
              
              // Shimmer Overlay (Holographic Effect)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.15)),
              ),

              // Info Gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.cardName,
                        style: PokemonTextStyles.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        card.setId.toUpperCase(),
                        style: PokemonTextStyles.inter(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index % 10 * 50).ms).scale(begin: const Offset(0.9, 0.9));
  }

  void _showCardDetails(CardData card) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(card.imageUrl, height: 400, fit: BoxFit.contain),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(card.cardName, style: PokemonTextStyles.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Expansion: ${card.setId.toUpperCase()}', style: PokemonTextStyles.inter(color: const Color(0xFFfbbf24), fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailCol('CARD ID', card.cardId),
                          _buildDetailCol('TYPE', 'Pokémon'),
                          _buildDetailCol('OWNED', '1x'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFfbbf24), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('CLOSE PREVIEW', style: PokemonTextStyles.inter(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          const CircularProgressIndicator(color: Color(0xFFfbbf24)),
          const SizedBox(height: 16),
          Text('SYNCING COLLECTION...', style: PokemonTextStyles.inter(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style_outlined, color: Colors.white10, size: 80),
          const SizedBox(height: 20),
          Text('NO CARDS FOUND', style: PokemonTextStyles.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          Text('Search criteria returned 0 results.', style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.setsPath),
            child: const Text('ACQUIRE PACKS'),
          ),
        ],
      ),
    );
  }
}

