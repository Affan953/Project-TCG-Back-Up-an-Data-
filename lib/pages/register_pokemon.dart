import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/providers/auth_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/widgets/glass_card.dart';
import 'package:tcg_pokemon/widgets/pikachu_character.dart';
import 'package:tcg_pokemon/widgets/pokemon_background.dart';
import 'package:tcg_pokemon/widgets/pokemon_text_styles.dart';

class PokemonTcgRegisterApp extends StatefulWidget {
  const PokemonTcgRegisterApp({super.key});

  @override
  State<PokemonTcgRegisterApp> createState() => _PokemonTcgRegisterAppState();
}

class _PokemonTcgRegisterAppState extends State<PokemonTcgRegisterApp> {
  final GlobalKey<PikachuCharacterState> _pikachuKey = GlobalKey<PikachuCharacterState>();
  
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  Timer? _typingDebounce;

  PikachuState _pikachuState = PikachuState.idle;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _hasSparkles = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _confirmFocus.addListener(_onFocusChange);
    
    _nameController.addListener(_onTextChange);
    _emailController.addListener(_onTextChange);
  }

  void _onFocusChange() {
    setState(() {
      if (_nameFocus.hasFocus || _emailFocus.hasFocus) {
        _pikachuState = PikachuState.typingEmail;
      } else if (_passwordFocus.hasFocus || _confirmFocus.hasFocus) {
        _pikachuState = PikachuState.typingPassword;
      } else {
        _pikachuState = PikachuState.idle;
      }
    });
  }

  void _onTextChange() {
    setState(() {
      _hasSparkles = _nameController.text.isNotEmpty || _emailController.text.isNotEmpty;
    });
  }

  void _handleKeyPress() {
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 350), () {
      _pikachuKey.currentState?.triggerLightning();
    });
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap isi semua field!'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password dan konfirmasi password tidak cocok!'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (!mounted) return;

    setState(() => _isRegistering = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registrasi berhasil! Silakan login. 🎉'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Navigate back to login
      context.go(AppRoutes.loginPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registrasi gagal!'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
  @override
  void dispose() {
    _typingDebounce?.cancel();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: PokemonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 32),
                          
                          _buildField('Trainer Name', 'Ash Ketchum', _nameController, _nameFocus),
                          const SizedBox(height: 20),
                          _buildField('Email Address', 'trainer@pokemon.com', _emailController, _emailFocus),
                          const SizedBox(height: 20),
                          _buildPasswordField('Password', _passwordController, _passwordFocus, _isPasswordVisible, (v) => setState(() => _isPasswordVisible = v)),
                          const SizedBox(height: 20),
                          _buildPasswordField('Confirm Password', _confirmController, _confirmFocus, _isConfirmVisible, (v) => setState(() => _isConfirmVisible = v)),
                          
                          const SizedBox(height: 24),
                          if (authProvider.errorMessage != null)
                            Column(
                              children: [
                                Text(
                                  authProvider.errorMessage!,
                                  style: PokemonTextStyles.inter(color: Colors.redAccent, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          _buildPrimaryButton(authProvider.isLoading),
                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 24),
                          _buildGoogleButton(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -60, // Moved higher to clear "TCGI" title
                    child: PikachuCharacter(
                      key: _pikachuKey,
                      state: _pikachuState,
                      hasText: _hasSparkles,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildBottomLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFfbbf24), Color(0xFFfde047), Color(0xFFeab308)],
          ).createShader(bounds),
          child: Text('TCGI', style: PokemonTextStyles.brandLogo(color: Colors.white)),
        ),
        const SizedBox(height: 12),
        Text('Trainer Registration Portal', style: PokemonTextStyles.subtitle()),
      ],
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PokemonTextStyles.inter()),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => _handleKeyPress(),
          style: PokemonTextStyles.inter(fontSize: 16),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, FocusNode focusNode, bool isVisible, Function(bool) toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PokemonTextStyles.inter()),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => _handleKeyPress(),
          obscureText: !isVisible,
          style: PokemonTextStyles.inter(fontSize: 16),
          decoration: _inputDecoration('••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(isVisible ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.white.withOpacity(0.6), size: 20),
              onPressed: () => toggle(!isVisible),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: PokemonTextStyles.inter(
        color: Colors.white.withOpacity(0.35),
        fontSize: 16,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFF60A5FA).withOpacity(0.5),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(bool isLoading) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3b82f6), Color(0xFF1d4ed8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3b82f6).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isRegistering ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isRegistering)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            else
              Text(
                'Begin Your Adventure',
                style: PokemonTextStyles.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            Positioned.fill(
              child: Container()
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    delay: 2000.ms,
                    duration: 1500.ms,
                    color: Colors.white.withOpacity(0.2),
                  ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: PokemonTextStyles.inter(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          backgroundColor: Colors.white.withOpacity(0.1),
        ),
        child: Text('Continue with Google', style: PokemonTextStyles.inter(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildBottomLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already a Trainer? ', style: PokemonTextStyles.inter(color: Colors.white.withOpacity(0.7))),
        GestureDetector(
          onTap: () => context.go(AppRoutes.loginPath),
          child: Text('Sign In', style: PokemonTextStyles.inter(color: const Color(0xFFfbbf24), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
