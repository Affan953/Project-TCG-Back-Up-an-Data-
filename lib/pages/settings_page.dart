import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/providers/auth_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pikachu_character.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<PikachuCharacterState> _pikachuKey = GlobalKey<PikachuCharacterState>();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.userData;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'TRAINER HUB',
          style: PokemonTextStyles.brandLogo(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_filled, color: Colors.white, size: 24),
            onPressed: () => context.go(AppRoutes.homePath),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: PokemonBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              
              // Animated Mascot
              Center(
                child: GestureDetector(
                  onTap: () {
                    _pikachuKey.currentState?.triggerLightning();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pika! Pika!', style: PokemonTextStyles.inter(fontWeight: FontWeight.bold)),
                        backgroundColor: const Color(0xFFfbbf24),
                        duration: 1.seconds,
                        behavior: SnackBarBehavior.floating,
                        width: 120,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                  child: PikachuCharacter(
                    key: _pikachuKey,
                    state: PikachuState.idle,
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.7, 0.7)),

              const SizedBox(height: 8),

              // Deluxe Profile Card
              _buildDeluxeProfileCard(userData),
              
              const SizedBox(height: 20),

              // Premium Wallet Shortcut
              _buildPremiumWalletShortcut(authProvider),

              const SizedBox(height: 32),

              // Settings Sections
              _buildCategorizedSettings(context, authProvider),

              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutAction(context, authProvider),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeluxeProfileCard(Map<String, dynamic>? userData) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563eb).withOpacity(0.2),
            const Color(0xFF1e40af).withOpacity(0.4),
          ],
        ),
        border: Border.all(color: const Color(0xFF60a5fa).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Icon(Icons.stars_rounded, size: 150, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _buildAvatarWithGlow(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['username'] ?? 'Pokémon Trainer',
                          style: PokemonTextStyles.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          userData?['email'] ?? 'trainer@tcg-world.com',
                          style: PokemonTextStyles.inter(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        _buildRankBadge(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAvatarWithGlow() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)]),
        boxShadow: [BoxShadow(color: const Color(0xFFfbbf24).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
      ),
      child: CircleAvatar(
        radius: 42,
        backgroundColor: const Color(0xFF1e293b),
        child: Image.network(
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
          height: 65,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFfbbf24).withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFfbbf24).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFfbbf24), size: 14),
          const SizedBox(width: 6),
          Text(
            'ELITE TRAINER',
            style: PokemonTextStyles.inter(color: const Color(0xFFfbbf24), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWalletShortcut(AuthProvider auth) {
    final balance = auth.userData?['saldo'] ?? auth.userData?['sisa_saldo'] ?? auth.userData?['balance'] ?? 0;
    return GestureDetector(
      onTap: () => context.go(AppRoutes.topupPath),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10b981), size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('POKEMON WALLET', style: PokemonTextStyles.inter(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: PokemonTextStyles.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 18),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildCategorizedSettings(BuildContext context, AuthProvider auth) {
    return Column(
      children: [
        _buildSettingsSection(
          title: 'MASTER ACCOUNT',
          items: [
            _buildTile(
              Icons.person_pin_rounded, 
              const Color(0xFF60a5fa), 
              'Trainer Profile', 
              'Identity & Region',
              onTap: () => _showAccountInfoDialog(context, auth),
            ),
            _buildTile(
              Icons.vpn_key_rounded, 
              const Color(0xFFf87171), 
              'Access & Security', 
              'Password & Privacy',
              onTap: () => _showSecurityDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingsSection(
          title: 'PREFERENCES',
          items: [
            _buildToggleTile(Icons.bolt_rounded, const Color(0xFFfbbf24), 'Push Notifications', 'Real-time card alerts', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
            _buildToggleTile(Icons.brush_rounded, const Color(0xFFa78bfa), 'Dark Theme', 'Premium dark interface', _darkModeEnabled, (v) => setState(() => _darkModeEnabled = v)),
            _buildTile(
              Icons.language_rounded, 
              const Color(0xFF34d399), 
              'System Language', 
              _selectedLanguage == 'id' ? 'Bahasa Indonesia' : 'English',
              onTap: () => _showLanguageDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingsSection(
          title: 'PROFESSOR LAB',
          items: [
            _buildTile(
              Icons.contact_support_rounded, 
              const Color(0xFF60a5fa), 
              'Technical Support', 
              'Report wild bugs',
              onTap: () => _showHelpDialog(context),
            ),
            _buildTile(Icons.verified_rounded, Colors.white38, 'App Version', 'v1.4.5 [STABLE]', isActionable: false),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 10),
          child: Text(
            title,
            style: PokemonTextStyles.inter(color: const Color(0xFFfbbf24).withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ),
        GlassCard(
          child: Column(children: items),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTile(IconData icon, Color color, String title, String sub, {VoidCallback? onTap, bool isActionable = true}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(sub, style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 12)),
      trailing: isActionable ? const Icon(Icons.chevron_right_rounded, color: Colors.white12) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildToggleTile(IconData icon, Color color, String title, String sub, bool val, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(sub, style: PokemonTextStyles.inter(color: Colors.white38, fontSize: 12)),
      trailing: Switch.adaptive(value: val, onChanged: onChanged, activeColor: const Color(0xFFfbbf24)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutAction(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context, auth),
        icon: const Icon(Icons.logout_rounded),
        label: Text('ABANDON JOURNEY', style: PokemonTextStyles.inter(fontWeight: FontWeight.w900, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.08),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: const BorderSide(color: Colors.redAccent, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    ).animate().shimmer(duration: 3.seconds, color: Colors.red.withOpacity(0.1));
  }

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 24),
                Text('END SESSION?', style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 12),
                Text('Are you sure you want to exit the current trainer session?', textAlign: TextAlign.center, style: PokemonTextStyles.inter(color: Colors.white60)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), child: Text('STAY', style: PokemonTextStyles.inter(color: Colors.white38)))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await auth.logout();
                          if (mounted) context.go(AppRoutes.loginPath);
                        },
                        child: Text('LOGOUT', style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900)),
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

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_outlined, color: Color(0xFFf87171), size: 64),
                const SizedBox(height: 20),
                Text('SECURITY LOCK', style: PokemonTextStyles.brandLogo(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 16),
                Text(
                  'Your account is secured with 256-bit Pokedex encryption.',
                  textAlign: TextAlign.center,
                  style: PokemonTextStyles.inter(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf87171),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('PROTECTED', style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountInfoDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.badge_outlined, color: Color(0xFFfbbf24), size: 64),
                const SizedBox(height: 24),
                Text(
                  'TRAINER ID CARD',
                  style: PokemonTextStyles.brandLogo(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 32),
                _infoRow('Trainer Name', authProvider.userData?['username'] ?? 'N/A'),
                _infoRow('Email Address', authProvider.userData?['email'] ?? 'N/A'),
                _infoRow('Region', 'Kanto Area'),
                _infoRow('License', 'Master Collector'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFfbbf24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('ACKNOWLEDGE', style: PokemonTextStyles.inter(color: Colors.black, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: PokemonTextStyles.inter(color: Colors.white70, fontSize: 13)),
          Text(value, style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REGION SELECT',
                  style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: Text('Bahasa Indonesia', style: PokemonTextStyles.inter(color: Colors.white)),
                  trailing: _selectedLanguage == 'id' ? const Icon(Icons.check_circle, color: Color(0xFFfbbf24)) : null,
                  onTap: () {
                    setState(() => _selectedLanguage = 'id');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('English (International)', style: PokemonTextStyles.inter(color: Colors.white)),
                  trailing: _selectedLanguage == 'en' ? const Icon(Icons.check_circle, color: Color(0xFFfbbf24)) : null,
                  onTap: () {
                    setState(() => _selectedLanguage = 'en');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.support_agent_rounded, color: Color(0xFF60a5fa), size: 64),
                const SizedBox(height: 20),
                Text('POKEDEX SUPPORT', style: PokemonTextStyles.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 20),
                Text(
                  'Encountered a wild bug?\nContact our Professor immediately.\n\nEmail: support@tcg-mon.com',
                  textAlign: TextAlign.center,
                  style: PokemonTextStyles.inter(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('SYSTEM CLEAR', style: PokemonTextStyles.inter(color: const Color(0xFF60a5fa), fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}

