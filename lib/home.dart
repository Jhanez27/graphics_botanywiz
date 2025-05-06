import 'package:flutter/material.dart';

class Plant {
  final String id;
  final String name;
  final String image;
  final String description;

  Plant({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });
}

final List<Plant> plants = [
  Plant(
    id: '1',
    name: 'Buddha Belly',
    image: 'assets/budhhabelly.png',
    description:
        'A succulent plant known for its swollen base. It is used in traditional medicine and as a natural pesticide due to its ability to repel insects with its strong odor.',
  ),
  Plant(
    id: '2',
    name: 'Coleus',
    image: 'assets/coleus.png',
    description:
        'Coleus is a versatile ornamental plant with vibrant foliage. It contains compounds that act as natural insect repellents and can be used in organic pest control.',
  ),
  Plant(
    id: '3',
    name: 'Oregano',
    image: 'assets/origano.jpg',
    description:
        'Oregano is a culinary herb rich in antioxidants and antimicrobial properties. It has been used in traditional medicine and as a botanical pesticide to control pests like aphids.',
  ),
  Plant(
    id: '4',
    name: 'Cassava',
    image: 'assets/cassava.png',
    description:
        'Cassava is a staple root crop with high starch content. Its leaves contain cyanogenic compounds, which can be toxic to pests, and are sometimes used in natural pest control strategies.',
  ),
  Plant(
    id: '5',
    name: 'Insulin',
    image: 'assets/insulin.png',
    description:
        'Insulin is a hormone critical for regulating blood sugar. While not a plant itself, it can be derived from certain plants like the "insulin plant," which is believed to have therapeutic effects on diabetes and some pests.',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF657C6A),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 40, height: 40),
            const SizedBox(width: 8),
            const Text(
              'Botanywiz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Color(0xFF2E3D2E),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B6842),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'plant');
                },
                child: const Text(
                  'Identify Plant',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              plant.image,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            plant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            plant.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
