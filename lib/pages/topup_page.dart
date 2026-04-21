import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pikachu_character.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/providers/auth_provider.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<PikachuCharacterState> _pikachuKey = GlobalKey<PikachuCharacterState>();
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _topupResult;
  PikachuState _pikachuState = PikachuState.idle;
  int? _selectedPreset;

  final List<int> _presetAmounts = [50000, 100000, 200000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _performTopup() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorMessage = 'Masukkan jumlah topup');
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Jumlah topup harus berupa angka positif');
      return;
    }

    if (amount < 10000) {
      setState(() => _errorMessage = 'Minimal topup Rp 10.000');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _topupResult = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/users/topup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() => _topupResult = responseData);

        if (mounted) {
          final newBalance = responseData['saldo_baru'] ?? 
                             responseData['sisa_saldo'] ?? 
                             responseData['balance'] ?? 0;
          context.read<AuthProvider>().updateUserData({'saldo': newBalance});
        }

        _pikachuKey.currentState?.triggerLightning();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Topup berhasil! Saldo baru: Rp ${_formatCurrency(_topupResult!['saldo_baru'])}',
              style: PokemonTextStyles.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10b981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Topup gagal');
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectPresetAmount(int amount) {
    _amountController.text = amount.toString();
    _pikachuKey.currentState?.triggerLightning();
    setState(() {
      _selectedPreset = amount;
      _errorMessage = '';
    });
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
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
          'TRAINER WALLET',
          style: PokemonTextStyles.brandLogo(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
            onPressed: () {},
            tooltip: 'History',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PokemonBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Pikachu Mascot Interaction
              Center(
                child: GestureDetector(
                  onTap: () => _pikachuKey.currentState?.triggerLightning(),
                  child: PikachuCharacter(
                    key: _pikachuKey,
                    state: _pikachuState,
                    hasText: _amountController.text.isNotEmpty,
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 20),

              // Wallet Card
              _buildProfessionalWalletCard(),
              
              const SizedBox(height: 32),

              Text(
                'FAST RELOAD',
                style: PokemonTextStyles.inter(
                  color: const Color(0xFFfbbf24).withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Preset Amounts Grid
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: _presetAmounts.length,
                itemBuilder: (context, index) => _buildPresetChip(_presetAmounts[index]),
              ),

              const SizedBox(height: 32),

              Text(
                'MANUAL AMOUNT',
                style: PokemonTextStyles.inter(
                  color: const Color(0xFFfbbf24).withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildModernTextField(),

              if (_errorMessage.isNotEmpty) _buildErrorMessage(),

              const SizedBox(height: 32),
              _buildConfirmButton(),

              if (_topupResult != null) _buildDetailedReceipt(),

              const SizedBox(height: 32),
              _buildRecentActivityPreview(),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalWalletCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final balance = auth.userData?['saldo'] ?? auth.userData?['sisa_saldo'] ?? auth.userData?['balance'] ?? 0;
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1e3a8a).withOpacity(0.9),
                const Color(0xFF1e293b).withOpacity(0.95),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFfbbf24).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Abstract Mesh Pattern
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFfbbf24).withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Icon(Icons.wallet, size: 100, color: Colors.white.withOpacity(0.03)),
                ),
                
                // Card Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL BALANCE',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_formatCurrency(balance)}',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFfbbf24).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Color(0xFFfbbf24), size: 24),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRAINER NAME',
                                style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                auth.userData?['username']?.toUpperCase() ?? 'ASH KETCHUM',
                                style: PokemonTextStyles.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Image.network(
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
                            height: 40,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.05));
      },
    );
  }

  Widget _buildPresetChip(int amount) {
    bool isSelected = _selectedPreset == amount;
    return GestureDetector(
      onTap: () => _selectPresetAmount(amount),
      child: AnimatedContainer(
        duration: 300.ms,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFfbbf24) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFfbbf24) : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFFfbbf24).withOpacity(0.3), blurRadius: 10, spreadRadius: -2)
          ] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          '${_formatCurrency(amount / 1000).split('.')[0]}K',
          style: PokemonTextStyles.inter(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (val) {
          setState(() {
            _selectedPreset = null;
            _pikachuState = val.isNotEmpty ? PikachuState.typingEmail : PikachuState.idle;
          });
        },
        style: PokemonTextStyles.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'Minimum Rp 10.000',
          hintStyle: PokemonTextStyles.inter(color: Colors.white24, fontSize: 16),
          prefixIcon: const Icon(Icons.add_circle_outline, color: Color(0xFFfbbf24)),
          prefixText: 'Rp ',
          prefixStyle: PokemonTextStyles.inter(color: const Color(0xFFfbbf24), fontSize: 20, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performTopup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFfbbf24),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
          : Text('INITIATE TRANSFER', style: PokemonTextStyles.inter(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Text(_errorMessage, style: PokemonTextStyles.inter(color: Colors.redAccent, fontSize: 12)),
        ],
      ),
    ).animate().shake();
  }

  Widget _buildDetailedReceipt() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF10b981), size: 40),
              const SizedBox(height: 12),
              Text('TRANSFER SUCCESSFUL', style: PokemonTextStyles.inter(color: const Color(0xFF10b981), fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 20),
              _receiptRow('Amount Reloaded', 'Rp ${_formatCurrency(_topupResult!['topup_amount'])}'),
              _receiptRow('Previous Wallet', 'Rp ${_formatCurrency(_topupResult!['saldo_sebelumnya'])}'),
              const Divider(color: Colors.white12, height: 32),
              _receiptRow('New Balance', 'Rp ${_formatCurrency(_topupResult!['saldo_baru'])}', isTotal: true),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _receiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: PokemonTextStyles.inter(color: isTotal ? Colors.white : Colors.white54, fontSize: isTotal ? 14 : 12, fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal)),
          Text(value, style: PokemonTextStyles.inter(color: isTotal ? const Color(0xFFfbbf24) : Colors.white, fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITIES',
          style: PokemonTextStyles.inter(
            color: Colors.white24,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        _activityTile('Top Up Wallet', '+ Rp 100.000', 'Today, 10:42', Colors.greenAccent),
        _activityTile('Purchase Pack', '- Rp 25.000', 'Yesterday, 18:20', Colors.redAccent),
      ],
    );
  }

  Widget _activityTile(String title, String amount, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(amount.startsWith('+') ? Icons.add_circle_outline : Icons.shopping_bag_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(time, style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(amount, style: PokemonTextStyles.inter(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
