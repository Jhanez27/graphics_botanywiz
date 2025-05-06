import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class PlantPage extends StatefulWidget {
  const PlantPage({super.key});

  @override
  PlantPageState createState() => PlantPageState();
}

class PlantPageState extends State<PlantPage> {
  File? _image;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _plantDetails;

  late Interpreter _interpreter;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      setState(() => _isLoading = true);
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        'assets/kerasmodel.tflite',
        options: options,
      );
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n');
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load model: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _plantDetails = null;
        _error = null;
      });

      await _classifyImage(_image!);
    } catch (e) {
      setState(() => _error = 'Error picking image: $e');
    }
  }

  Future<void> _classifyImage(File image) async {
    try {
      final rawImage = await image.readAsBytes();
      img.Image? imageInput = img.decodeImage(rawImage);
      if (imageInput == null) {
        setState(() {
          _isLoading = false;
          _error = 'Could not decode image';
        });
        return;
      }

      final resized = img.copyResize(imageInput, width: 224, height: 224);
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(224, (x) {
            final pixel = resized.getPixel(x, y);
            return [
              img.getRed(pixel) / 255.0,
              img.getGreen(pixel) / 255.0,
              img.getBlue(pixel) / 255.0,
            ];
          }),
        ),
      );

      final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
      _interpreter.run(input, output);

      final scores = output[0];
      final maxScore = scores.reduce((a, b) => a > b ? a : b);
      final index = scores.indexOf(maxScore);

      setState(() {
        _isLoading = false;
        _plantDetails = _getPlantDetails(index, maxScore);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error classifying image: $e';
      });
    }
  }

  Map<String, dynamic> _getPlantDetails(int index, double confidence) {
    const plantDatabase = [
      {
        'name': 'Buddha Belly',
        'scientificName': 'Jatropha podagrica',
        'description':
            'Buddha Belly is a distinctive succulent known for its swollen, bottle-shaped trunk that stores water. It produces vibrant red flowers that attract pollinators, and its unique appearance makes it a popular ornamental plant. However, all parts of the plant are toxic if ingested.',
        'uses': 'Ornamental, traditional medicine',
        'habitat': 'Tropical, well-drained soil',
        'care': 'Water sparingly, 4-6hr sunlight',
      },
      {
        'name': 'Cassava',
        'scientificName': 'Manihot esculenta',
        'description':
            'Cassava is a hardy, drought-tolerant woody shrub cultivated primarily for its edible starchy tuberous roots. It is a major source of carbohydrates in many tropical countries and plays a vital role in food security. Proper processing is essential to remove naturally occurring cyanogenic compounds.',
        'uses': 'Food, starch, biofuel',
        'habitat': 'Tropical lowlands',
        'care': 'Warm, well-drained soil',
      },
      {
        'name': 'Coleus',
        'scientificName': 'Plectranthus scutellarioides',
        'description':
            'Coleus is a popular ornamental plant appreciated for its vibrant and varied leaf colors and patterns. It is widely used in gardens and indoor settings. The plant is relatively easy to propagate and is often associated with traditional medicinal uses in some cultures.',
        'uses': 'Decorative, traditional medicine',
        'habitat': 'Southeast Asia, Australia',
        'care': 'Partial shade, moist soil',
      },
      {
        'name': 'Insulin Plant',
        'scientificName': 'Costus igneus',
        'description':
            'The Insulin Plant is a medicinal herb believed to help regulate blood sugar levels, hence its name. It features spiral-shaped stems and broad green leaves with a mild, sweet taste. Often consumed as herbal tea or raw leaves, it is gaining popularity among natural health practitioners.',
        'uses': 'Diabetes management, herbal remedy',
        'habitat': 'Tropical regions, humid climate',
        'care': 'Partial shade, moist soil',
      },
      {
        'name': 'Oregano',
        'scientificName': 'Origanum vulgare',
        'description':
            'Oregano is a widely used aromatic herb known for its strong flavor and multiple health benefits. It contains potent antioxidants and antimicrobial compounds. Common in Mediterranean cooking, oregano is also used in herbal medicine for respiratory, digestive, and inflammatory conditions.',
        'uses': 'Culinary, antibacterial, antioxidant',
        'habitat': 'Mediterranean region',
        'care': 'Full sun, well-drained soil',
      },
    ];

    return index >= 0 && index < plantDatabase.length
        ? {
          ...plantDatabase[index],
          'confidence': '${(confidence * 100).toStringAsFixed(2)}%',
        }
        : {
          'name': 'Unknown Plant',
          'scientificName': 'Unknown',
          'description': 'Could not identify the plant.',
          'uses': 'N/A',
          'habitat': 'N/A',
          'care': 'N/A',
          'confidence': '${(confidence * 100).toStringAsFixed(2)}%',
        };
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  _image == null
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No image selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text(
                      "Gallery",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B6842),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      "Camera",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B6842),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Analyzing plant...'),
                ],
              ),
            if (_error != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_plantDetails != null) ...[
              const SizedBox(height: 20),
              _buildPlantCard(),
              _buildDetailCard('Description', _plantDetails!['description']),
              _buildDetailCard('Uses', _plantDetails!['uses']),
              _buildDetailCard('Natural Habitat', _plantDetails!['habitat']),
              _buildDetailCard('Care Instructions', _plantDetails!['care']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _plantDetails!['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _plantDetails!['scientificName'],
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Confidence: ${_plantDetails!['confidence']}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
