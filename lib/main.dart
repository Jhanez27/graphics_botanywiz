import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'plant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(VSUPlantApp(seenOnboarding: seenOnboarding));
}

class VSUPlantApp extends StatelessWidget {
  final bool seenOnboarding;

  const VSUPlantApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSU Plant Identifier',
      debugShowCheckedModeBanner: false,
      home: seenOnboarding ? const HomeScreen() : const OnboardingScreen(),
      routes: {
        'home': (context) => const HomeScreen(),
        'plant': (context) => const PlantPage(),
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to VSU Plant Identifier',
      'description':
          'Explore pesticidal and botanical plants found within the VSU campus.',
      'image': 'assets/image1.jpg',
    },
    {
      'title': 'Identify Plant',
      'description':
          'Snap or upload a photo of a plant to discover its name, uses.',
      'image': 'assets/image2.jpg',
    },
  ];

  void _handleNext() async {
    if (_currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      Navigator.pushReplacementNamed(context, 'home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: PageView.builder(
        controller: _controller,
        itemCount: onboardingData.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final item = onboardingData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['description']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  item['image']!,
                  width: size.width * 0.7,
                  height: size.height * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _handleNext,
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5B6842),
                          Color(0xFF626F47),
                          Color(0xFF6A7650),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        index == onboardingData.length - 1 ? 'Finish' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
