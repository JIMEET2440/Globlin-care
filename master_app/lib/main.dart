import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/environment_config.dart';
import 'login.dart';
import 'dashboard.dart';

// Brand Colors
const Color primaryBlue = Color(0xFF0052CC);
const Color accentGreen = Color(0xFF5BB318);
const Color lightGreen = Color(0xFFB3D42D);
const Color darkBlue = Color(0xFF003E99);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize environment configuration from .env file
  await EnvironmentConfig.init();
  runApp(const Globapp());
}

class Globapp extends StatelessWidget {
  const Globapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Globin Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const Splashscreen(title: 'Globin Care'),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashBoardScreen(),
      },
    );
  }
}

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key, required this.title});

  final String title;

  @override
  State<Splashscreen> createState() => _Splashstate();
}

class _Splashstate extends State<Splashscreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLoginStatus();
  }

  void _initializeAnimations() {
    // Fade animation for the whole content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for text
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 3.5 seconds to show splash animation
    await Future.delayed(const Duration(milliseconds: 3500));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // User was previously logged in, go to dashboard
        // done by provding routes in the GlobApp
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // User was not logged in, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F5FF), Color(0xFFF5F9E6)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 160,
                    height: 160,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF0F5FF),
                      
                    ),
                    child: Image.asset(
                      "assets/images/Globin_preview.png",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.health_and_safety_rounded,
                          size: 80,
                          color: primaryBlue,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Animated Text
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'GLOBIN',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: primaryBlue,
                                letterSpacing: 2,
                              ),
                            ),
                            TextSpan(text: ' ', style: TextStyle(fontSize: 32)),
                            TextSpan(
                              text: 'CARE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: accentGreen,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentGreen, primaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Healthcare Excellence',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//                       "assets/images/Final_logo.png",
//                       width: 250,
//                       height: 250,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const SizedBox(
//                           width: 150,
//                           height: 150,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   const Color.fromARGB(255, 164, 213, 255),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Text("Loading your health")
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
