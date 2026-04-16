import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum PikachuState { idle, typingEmail, typingPassword }

class PikachuCharacter extends StatefulWidget {
  final PikachuState state;
  final bool hasText;

  const PikachuCharacter({
    super.key,
    required this.state,
    this.hasText = false,
  });

  @override
  State<PikachuCharacter> createState() => PikachuCharacterState();
}

class PikachuCharacterState extends State<PikachuCharacter> with TickerProviderStateMixin {
  final List<Widget> _lightningBolts = [];
  bool _isLightningActive = false;

  void triggerLightning() {
    final randomType = math.Random().nextInt(5) + 1;
    final key = UniqueKey();
    
    setState(() {
      _isLightningActive = true;
      _lightningBolts.add(
        _LightningBoltWidget(
          key: key,
          type: randomType,
          onComplete: () {
            if (mounted) {
              setState(() {
                _lightningBolts.removeWhere((w) => w.key == key);
                if (_lightningBolts.isEmpty) _isLightningActive = false;
              });
            }
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 640;
    final size = isDesktop ? 224.0 : 192.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Glow Effect (Pulses slower)
        _PikachuGlow(isActive: _isLightningActive),

        // Pikachu Image with Layers of Animations
        _SmoothPikachu(
          state: widget.state,
          size: size,
          hasText: widget.hasText,
        ),

        // Lightning Bolts Layer (Always on top)
        ..._lightningBolts,

        // Sparkles (Only when typing email/name and has text)
        if (widget.state == PikachuState.typingEmail && widget.hasText)
          const _SparklesLayer(),
      ],
    );
  }
}

class _SmoothPikachu extends StatelessWidget {
  final PikachuState state;
  final double size;
  final bool hasText;

  const _SmoothPikachu({
    required this.state,
    required this.size,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Core Image
    Widget content = Image.asset(
      'assets/images/Pika.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // 2. Continuous Idle Layer (Breathing + Small Wobble)
    // We apply these FIRST so they are always active regardless of the outer transform
    content = content
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.03, 1.03),
          duration: 2500.ms,
          curve: Curves.easeInOut,
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.01,
          end: 0.01,
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );

    // 3. State-Driven Transform Layer
    // This handles Head Turn or Shy transitions smoothly using AnimatedContainer
    return AnimatedContainer(
      duration: 500.ms,
      curve: Curves.easeOutCubic,
      transformAlignment: Alignment.center,
      transform: _getTransform(),
      child: content,
    );
  }

  Matrix4 _getTransform() {
    switch (state) {
      case PikachuState.typingEmail:
        // Head Turn: rotateY, rotateZ, translateX
        return Matrix4.identity()
          ..translate(-10.0, 0.0)
          ..rotateY(-25 * math.pi / 180)
          ..rotateZ(-5 * math.pi / 180);
      case PikachuState.typingPassword:
        // Shy: move down and scale smaller
        return Matrix4.identity()
          ..translate(0.0, 20.0)
          ..scale(0.85, 0.85);
      case PikachuState.idle:
        return Matrix4.identity();
    }
  }
}

class _PikachuGlow extends StatelessWidget {
  final bool isActive;
  const _PikachuGlow({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFfacc15).withOpacity(isActive ? 0.45 : 0.25),
            const Color(0xFFeab308).withOpacity(isActive ? 0.2 : 0.1),
            Colors.transparent,
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
    .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.5, 1.5), duration: 2000.ms);
  }
}

class _LightningBoltWidget extends StatefulWidget {
  final int type;
  final VoidCallback onComplete;

  const _LightningBoltWidget({
    super.key,
    required this.type,
    required this.onComplete,
  });

  @override
  State<_LightningBoltWidget> createState() => _LightningBoltWidgetState();
}

class _LightningBoltWidgetState extends State<_LightningBoltWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<String> paths = [
    "M 25 0 L 15 30 L 25 30 L 10 80 L 35 35 L 25 35 Z",
    "M 30 0 L 20 35 L 30 35 L 15 80 L 40 40 L 30 40 Z",
    "M 25 0 L 18 28 L 25 28 L 12 70 L 32 32 L 25 32 Z",
    "M 28 0 L 20 32 L 28 32 L 14 75 L 36 36 L 28 36 Z",
    "M 22 0 L 16 25 L 22 25 L 10 65 L 28 30 L 22 30 Z",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 450.ms);
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double t = 0, l = 0, r = 0, b = 0;
    // Spread them out more randomly based on type
    switch (widget.type) {
      case 1: t = -60; l = -80; break;
      case 2: t = -80; r = -60; break;
      case 3: b = 20; l = -90; break;
      case 4: b = -40; r = -70; break;
      case 5: t = 40; r = -95; break;
    }

    return Positioned(
      top: t != 0 ? t : null,
      left: l != 0 ? l : null,
      right: r != 0 ? r : null,
      bottom: b != 0 ? b : null,
      child: FadeTransition(
        opacity: _controller.drive(TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
          TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
        ])),
        child: ScaleTransition(
          scale: _controller.drive(Tween(begin: 0.7, end: 1.1)),
          child: SvgPicture.string(
            '''<svg viewBox="0 0 50 80" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <filter id="glow">
                  <feGaussianBlur stdDeviation="2" result="blur" />
                  <feComposite in="SourceGraphic" in2="blur" operator="over" />
                </filter>
              </defs>
              <path d="${paths[widget.type - 1]}" fill="#fef08a" opacity="0.9" filter="url(#glow)" />
              <path d="${paths[widget.type - 1]}" fill="none" stroke="#fbbf24" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            </svg>''',
            width: 70,
            height: 90,
          ),
        ),
      ),
    );
  }
}

class _SparklesLayer extends StatelessWidget {
  const _SparklesLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSparkle(top: 10, left: 10, color: const Color(0xFFfde047), delay: 0.ms),
        _buildSparkle(top: 80, right: 10, color: Colors.white, delay: 200.ms),
        _buildSparkle(bottom: 20, left: 30, color: const Color(0xFFfef08a), delay: 400.ms),
      ],
    );
  }

  Widget _buildSparkle({double? top, double? left, double? right, double? bottom, required Color color, required Duration delay}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.star, color: color, size: 14)
          .animate(onPlay: (c) => c.repeat())
          .fadeIn(duration: 400.ms, delay: delay)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 600.ms, curve: Curves.elasticOut, delay: delay)
          .move(begin: const Offset(0, 0), end: const Offset(0, -30), duration: 1000.ms, delay: delay)
          .fadeOut(duration: 400.ms, delay: delay + 600.ms),
    );
  }
}
