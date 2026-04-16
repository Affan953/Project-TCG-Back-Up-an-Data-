import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/providers/auth_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
              'Settings',
              style: PokemonTextStyles.brandLogo(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola pengaturan aplikasi',
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
        ],
      ),
      body: PokemonBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 104),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Section
                      Text(
                        'Akun',
                        style: PokemonTextStyles.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Informasi Akun',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                authProvider.userData?['username'] ?? 'User',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 16,
                              ),
                              onTap: () {
                                // Show account info dialog
                                _showAccountInfoDialog(context, authProvider);
                              },
                            ),
                            const Divider(color: Colors.white24),
                            ListTile(
                              leading: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Top Up Saldo',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Tambah saldo untuk fitur premium',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 16,
                              ),
                              onTap: () => context.go(AppRoutes.topupPath),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Preferences Section
                      Text(
                        'Preferensi',
                        style: PokemonTextStyles.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                'Notifikasi',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Terima notifikasi update kartu baru',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              activeColor: const Color(0xFFfbbf24),
                            ),
                            const Divider(color: Colors.white24),
                            SwitchListTile(
                              title: Text(
                                'Dark Mode',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Mode gelap untuk aplikasi',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              value: _darkModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _darkModeEnabled = value;
                                });
                                // TODO: Implement theme switching
                              },
                              activeColor: const Color(0xFFfbbf24),
                            ),
                            const Divider(color: Colors.white24),
                            ListTile(
                              leading: const Icon(
                                Icons.language,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Bahasa',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                _selectedLanguage == 'id' ? 'Bahasa Indonesia' : 'English',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 16,
                              ),
                              onTap: () => _showLanguageDialog(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Info Section
                      Text(
                        'Tentang Aplikasi',
                        style: PokemonTextStyles.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.info,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Versi Aplikasi',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '1.0.0',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            ListTile(
                              leading: const Icon(
                                Icons.help,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Bantuan & Dukungan',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'FAQ dan kontak dukungan',
                                style: PokemonTextStyles.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 16,
                              ),
                              onTap: () => _showHelpDialog(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Logout Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(context, authProvider),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Informasi Akun',
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAccountInfoRow('Username', authProvider.userData?['username'] ?? 'N/A'),
                _buildAccountInfoRow('Email', authProvider.userData?['email'] ?? 'N/A'),
                _buildAccountInfoRow('Status', 'Aktif'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfbbf24),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: PokemonTextStyles.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: PokemonTextStyles.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Bahasa',
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Bahasa Indonesia',
                    style: PokemonTextStyles.inter(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  trailing: _selectedLanguage == 'id'
                    ? const Icon(Icons.check, color: Color(0xFFfbbf24))
                    : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'id';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(
                    'English',
                    style: PokemonTextStyles.inter(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  trailing: _selectedLanguage == 'en'
                    ? const Icon(Icons.check, color: Color(0xFFfbbf24))
                    : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'en';
                    });
                    Navigator.of(context).pop();
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bantuan & Dukungan',
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Untuk bantuan dan dukungan, silakan hubungi:\n\nEmail: support@tcg-pokemon.com\n\nAtau kunjungi halaman FAQ di website kami.',
                  style: PokemonTextStyles.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfbbf24),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Konfirmasi Logout',
                  style: PokemonTextStyles.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Apakah Anda yakin ingin logout dari aplikasi?',
                  style: PokemonTextStyles.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Batal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go(AppRoutes.loginPath);
                        }
                      },
                      child: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
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