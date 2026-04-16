import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/providers/auth_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';
import 'package:tcg_pokemon/routes/app_router.dart';

class LoadingPokemon extends StatefulWidget {
  const LoadingPokemon({super.key});

  @override
  State<LoadingPokemon> createState() => _LoadingPokemonState();
}

class _LoadingPokemonState extends State<LoadingPokemon> {
  double _percentage = 0;
  String _loadingText = "Loading Trainer Portal...";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
    _startLoading();
  }

  Future<void> _tryAutoLogin() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_percentage < 100) {
          _percentage += math.Random().nextInt(5) + 1;
          if (_percentage > 100) _percentage = 100;
        } else {
          _loadingText = "Access Granted.";
          _timer.cancel();
          
          // Mark as shown
          hasShownLoading = true;

          // Check if user is logged in
          final authProvider = context.read<AuthProvider>();
          final redirectLocation = authProvider.isLoggedIn 
            ? AppRoutes.homePath 
            : (GoRouterState.of(context).uri.queryParameters['redirect'] ?? AppRoutes.loginPath);

          // Navigate after short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.go(redirectLocation);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF1c2541),
              Color(0xFF0a1128),
            ],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Particles
            ...List.generate(25, (index) => const _Particle()),
            
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TCGI",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 32,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 1500.ms).slideY(begin: 0.5, end: 0),
                  
                  const SizedBox(height: 48),
                  
                  const _PokeballLoader(),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    "${_percentage.toInt()}%",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _loadingText,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: _percentage >= 100 ? const Color(0xFFa8dadc) : const Color(0xFF8d99ae),
                      letterSpacing: 1,
                    ),
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

class _PokeballLoader extends StatelessWidget {
  const _PokeballLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFe63946).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 2.seconds),
          
          // Pokeball
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1d3557), width: 4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFe63946),
                  Color(0xFFe63946),
                  Color(0xFF1d3557),
                  Color(0xFF1d3557),
                  Color(0xFFf1faee),
                  Color(0xFFf1faee),
                ],
                stops: [0.0, 0.47, 0.47, 0.53, 0.53, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(-5, -5),
                  blurRadius: 15,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center button
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1faee),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1d3557), width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(-2, -2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Center dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .custom(
                   duration: 1200.ms,
                   builder: (context, value, child) => Opacity(
                     opacity: 0.5 + (value * 0.5),
                     child: Container(
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         boxShadow: [
                           BoxShadow(
                             color: Colors.white.withOpacity(value * 0.8),
                             blurRadius: 10 * value,
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .rotate(duration: 1200.ms, curve: const Cubic(0.68, -0.55, 0.265, 1.55)),
        ],
      ),
    );
  }
}

class _Particle extends StatefulWidget {
  const _Particle();

  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle> {
  late double _left;
  late double _size;
  late Duration _duration;
  late Duration _delay;

  @override
  void initState() {
    super.initState();
    _randomize();
  }

  void _randomize() {
    final random = math.Random();
    _left = random.nextDouble() * 100;
    _size = random.nextDouble() * 4 + 1;
    _duration = Duration(seconds: random.nextInt(10) + 5);
    _delay = Duration(seconds: random.nextInt(5));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * (_left / 100),
      bottom: -20,
      child: Container(
        width: _size,
        height: _size,
        decoration: const BoxDecoration(
          color: Colors.white30,
          shape: BoxShape.circle,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .moveY(
         begin: 0,
         end: -MediaQuery.of(context).size.height - 50,
         duration: _duration,
         delay: _delay,
       )
       .scale(begin: const Offset(0, 0), end: const Offset(1.5, 1.5))
       .fadeIn(duration: Duration(milliseconds: (_duration.inMilliseconds * 0.2).toInt()))
       .fadeOut(delay: Duration(milliseconds: (_duration.inMilliseconds * 0.8).toInt())),
    );
  }
}
