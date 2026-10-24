import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantit/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => widget.nextScreen,
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF43A047),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated seedling illustration (emoji-based, works everywhere)
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(60), width: 2),
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 72)),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 32),

              // App name
              Text(
                'PlantIT',
                style: GoogleFonts.outfit(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              )
              .animate(delay: const Duration(milliseconds: 400))
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideY(begin: 0.3, end: 0.0),

              const SizedBox(height: 10),

              // Tagline
              Text(
                'Kerala Urban Farming · AI Powered',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withAlpha(200),
                  letterSpacing: 0.5,
                ),
              )
              .animate(delay: const Duration(milliseconds: 700))
              .fadeIn(duration: const Duration(milliseconds: 600)),

              const SizedBox(height: 6),

              Text(
                'കൃഷി ചെയ്യൂ • ഉണ്ണൂ • ജീവിക്കൂ',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withAlpha(170),
                ),
              )
              .animate(delay: const Duration(milliseconds: 900))
              .fadeIn(duration: const Duration(milliseconds: 600)),

              const Spacer(flex: 2),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(180)),
                ),
              )
              .animate(delay: const Duration(milliseconds: 1200))
              .fadeIn(duration: const Duration(milliseconds: 500)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
