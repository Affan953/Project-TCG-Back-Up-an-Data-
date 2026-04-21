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

class PokemonTcgLoginApp extends StatefulWidget {
  const PokemonTcgLoginApp({super.key});

  @override
  State<PokemonTcgLoginApp> createState() => _PokemonTcgLoginAppState();
}

class _PokemonTcgLoginAppState extends State<PokemonTcgLoginApp> {
  final GlobalKey<PikachuCharacterState> _pikachuKey =
      GlobalKey<PikachuCharacterState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Timer? _typingDebounce;

  PikachuState _pikachuState = PikachuState.idle;
  bool _isPasswordVisible = false;
  bool _hasEmailText = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _emailController.addListener(_onEmailChange);
  }

  void _onFocusChange() {
    setState(() {
      if (_emailFocus.hasFocus) {
        _pikachuState = PikachuState.typingEmail;
      } else if (_passwordFocus.hasFocus) {
        _pikachuState = PikachuState.typingPassword;
      } else {
        _pikachuState = PikachuState.idle;
      }
    });
  }

  void _onEmailChange() {
    setState(() {
      _hasEmailText = _emailController.text.isNotEmpty;
    });
  }

  void _handleKeyPress() {
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 350), () {
      _pikachuKey.currentState?.triggerLightning();
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap isi email dan password!'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoggingIn = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoggingIn = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login berhasil!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Navigate to home page
      context.go(AppRoutes.homePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login gagal!'),
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
    _emailFocus.removeListener(_onFocusChange);
    _passwordFocus.removeListener(_onFocusChange);
    _emailController.removeListener(_onEmailChange);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Glass Card
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title Section
                          _buildTitle(),
                          const SizedBox(height: 32),

                          // Form Section
                          _buildEmailField(),
                          const SizedBox(height: 24),
                          _buildPasswordField(),
                          _buildForgotPassword(),
                          const SizedBox(height: 24),
                          _buildPrimaryButton(),
                          const SizedBox(height: 32),
                          _buildDivider(),
                          const SizedBox(height: 32),
                          _buildGoogleButton(),
                        ],
                      ),
                    ),
                  ),

                  // Pikachu Overlap
                  Positioned(
                    top: -60, // Moved higher to clear "TCGI" title
                    child: PikachuCharacter(
                      key: _pikachuKey,
                      state: _pikachuState,
                      hasText: _hasEmailText,
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
          child: Text(
            'TCGI',
            style: PokemonTextStyles.brandLogo(color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text('Trainer Login Portal', style: PokemonTextStyles.subtitle()),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: PokemonTextStyles.inter(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          focusNode: _emailFocus,
          onChanged: (_) => _handleKeyPress(),
          style: PokemonTextStyles.inter(fontSize: 16),
          decoration: _inputDecoration('trainer_username'),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: PokemonTextStyles.inter(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          onChanged: (_) => _handleKeyPress(),
          obscureText: !_isPasswordVisible,
          style: PokemonTextStyles.inter(fontSize: 16),
          decoration: _inputDecoration('••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Forgot Password?',
          style: PokemonTextStyles.inter(
            color: const Color(0xFF93c5fd),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      height: 56,
      width: double.infinity,
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
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoggingIn ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isLoggingIn)
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
                'Start Your Journey',
                style: PokemonTextStyles.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            // Subtle shimmer effect
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
          child: Text(
            'OR',
            style: PokemonTextStyles.inter(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          backgroundColor: Colors.white.withOpacity(0.1),
        ),
        child: Text(
          'Continue with Google',
          style: PokemonTextStyles.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New Trainer? ',
          style: PokemonTextStyles.inter(color: Colors.white.withOpacity(0.7)),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.registerPath),
          child: Text(
            'Create Account',
            style: PokemonTextStyles.inter(
              color: const Color(0xFFfbbf24),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
