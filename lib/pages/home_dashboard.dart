import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<PokemonSet> _allSets = [];
  List<PokemonSet> _displayedSets = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _error = '';
  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _isDarkMode = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    _fetchSets();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _displayedSets.length < _allSets.length) {
      _loadMore();
    }
  }

  Future<void> _fetchSets() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('https://api-tcg-backend.vercel.app/api/pokemon/sets'),
        headers: headers.isNotEmpty ? headers : null,
      );

      print(response.statusCode);
      print(token);

      if (response.statusCode == 200) {
        final List<dynamic> setsData = json.decode(response.body);

        _allSets = setsData.map((json) => PokemonSet.fromJson(json)).toList();
        _applyFilter();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah habis (401). Silakan login kembali.');
      } else {
        throw Exception('Failed to load sets (Status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    List<PokemonSet> filtered = _allSets;

    if (_searchQuery.isNotEmpty) {
      filtered = _allSets.where((set) {
        return set.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            set.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _displayedSets = filtered;
      _currentPage = 0;
    });
  }

  void _loadMore() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

  List<PokemonSet> get _paginatedSets {
    final end = (_currentPage + 1) * _pageSize;
    return _displayedSets.take(end).toList();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = '';
        return AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF2D2D44) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Search Sets',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: 'Enter set name or series...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: _isDarkMode
                  ? const Color(0xFF1A1A2E)
                  : Colors.grey[100],
            ),
            onChanged: (value) => query = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = query;
                  _applyFilter();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Search', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? _darkTheme() : _lightTheme(),
      child: Scaffold(
        backgroundColor: _isDarkMode
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF5F5F5),
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isDarkMode
                  ? [Colors.transparent, Colors.black.withOpacity(0.3)]
                  : [Colors.transparent, Colors.white.withOpacity(0.3)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _fetchSets,
            color: const Color(0xFFEF5350),
            child: Stack(children: [_buildMainContent()]),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'pokemon_logo',
            child: Image.network(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
              height: 35,
              width: 35,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'PokéTCG',
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: _isDarkMode ? Colors.white : const Color(0xFFEF5350),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: _showSearchDialog,
        ),
        Hero(
          tag: 'profile_avatar',
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFEF5350), const Color(0xFFF48FB1)],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                    height: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pokémon TCG',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Collect & Battle',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', 0),
            _buildDrawerItem(Icons.collections_bookmark, 'Sets', 1),
            _buildDrawerItem(Icons.collections, 'Koleksi Kartu', 2),
            _buildDrawerItem(Icons.favorite, 'Favorites', 3),
            _buildDrawerItem(Icons.settings, 'Settings', 4),
            _buildDrawerItem(Icons.account_balance_wallet, 'Top Up', 5),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.brightness_6, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Dark Mode',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isDarkMode,
                    onChanged: (_) => _toggleTheme(),
                    activeColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      selectedTileColor: Colors.white.withOpacity(0.15),
      onTap: () => _navigateToPage(index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _navigateToPage(int index) {
    if (_selectedIndex == index && index == 0) {
      Navigator.pop(context);
      return;
    }

    // Close the drawer first to avoid potential UI freeze or overlay issues
    Navigator.pop(context);

    // Direct navigation using GoRouter
    switch(index) {
      case 0: // Home
        if (_selectedIndex != 0) {
          context.go(AppRoutes.homePath);
        }
        break;
      case 1: // Sets
        context.go(AppRoutes.setsPath);
        break;
      case 2: // Cards (My Cards Collection)
        context.go(AppRoutes.myCardsPath);
        break;
      case 3: // Favorites
        context.go(AppRoutes.favoritesPath);
        break;
      case 4: // Settings
        context.go(AppRoutes.settingsPath);
        break;
      case 5: // Top Up
        context.go(AppRoutes.topupPath);
        break;
    }
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_error.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_displayedSets.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Results for: ',
                  style: GoogleFonts.poppins(
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  '$_searchQuery',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF5350),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilter();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _paginatedSets.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _paginatedSets.length) {
                return _buildLoadingMore();
              }
              return _buildAnimatedCard(_paginatedSets[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(PokemonSet set, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildPokemonCard(set),
    );
  }

  Widget _buildPokemonCard(PokemonSet set) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            // transform: isHovered ? Matrix4.identity()..translate(0, -8) : Matrix4.identity(),
            child: GestureDetector(
              onTap: () => _navigateToDetail(set),
              child: Card(
                elevation: isHovered ? 12 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: _isDarkMode
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2D2D44), Color(0xFF1A1A2E)],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFF5F5F5)],
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: const Color(0xFFEF5350).withOpacity(0.1),
                              child: set.logo.isNotEmpty
                                  ? Image.network(
                                      set.logo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Image.network(
                                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                                            height: 60,
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Image.network(
                                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                                        height: 60,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sell,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Rp ${set.price}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              set.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              set.description,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _isDarkMode
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => ShimmerCard(isDarkMode: _isDarkMode),
    );
  }

  Widget _buildLoadingMore() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF5350)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.pikachu, size: 80, color: const Color(0xFFEF5350)),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchSets,
            icon: const Icon(Icons.refresh),
            label: Text('Try Again', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'No Pokémon Sets Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _applyFilter();
              });
            },
            icon: const Icon(Icons.clear),
            label: Text('Clear Search', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(PokemonSet set) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SetDetailScreen(
              set: set,
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFFEF5350),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFEF5350),
        secondary: Color(0xFF42A5F5),
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFEF5350),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEF5350),
        secondary: Color(0xFF42A5F5),
        surface: Color(0xFF2D2D44),
        background: Color(0xFF1A1A2E),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class PokemonSet {
  final String id;
  final String name;
  final String description;
  final int price;
  final String logo;

  PokemonSet({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.logo,
  });

  factory PokemonSet.fromJson(Map<String, dynamic> json) {
    return PokemonSet(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Set',
      description: json['description'] ?? 'Unknown Description',
      price: json['price'] is int ? json['price'] : 0,
      logo: json['logo'] ?? '',
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final bool isDarkMode;
  const ShimmerCard({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF2D2D44), const Color(0xFF1A1A2E)]
                : [Colors.grey[300]!, Colors.grey[200]!],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 100,
                    color: isDarkMode
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 70,
                    color: isDarkMode
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: 90,
                    color: isDarkMode
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey[200],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetDetailScreen extends StatelessWidget {
  final PokemonSet set;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SetDetailScreen({
    super.key,
    required this.set,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          set.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: Hero(
        tag: 'pokemon_logo',
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            const Color(0xFFEF5350).withOpacity(0.3),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFEF5350).withOpacity(0.2),
                            Colors.transparent,
                          ],
                  ),
                ),
                child: set.logo.isNotEmpty
                    ? Image.network(set.logo, fit: BoxFit.contain)
                    : Center(
                        child: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                          height: 100,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set.name,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      set.description,
                      style: GoogleFonts.poppins(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoRow(Icons.sell, 'Harga', 'Rp ${set.price}'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.code, 'Set ID', set.id.toUpperCase()),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFEF5350)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
