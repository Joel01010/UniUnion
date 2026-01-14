import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../domain/entities/lost_found_post.dart';
import '../../../core/services/location_service.dart';

class ReFindAIService {
  final LocationService _locationService;

  ReFindAIService(this._locationService);
  
  Future<Map<String, dynamic>> processImage(File imageFile) async {
    // 1. Get current location
    final locationResult = await _locationService.getCurrentLocationWithAddress();
    
    // 2. Text Recognition
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);
    final recognisedText = await textRecognizer.processImage(inputImage);
    final String fullText = recognisedText.text;
    
    // 3. Image Labeling
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    final labels = await imageLabeler.processImage(inputImage);
    
    final List<String> detectedLabels = labels.map((l) => l.label).take(5).toList();
    
    // 4. Generate title from detected labels
    String title = "Found Item";
    if (detectedLabels.isNotEmpty) {
      title = "${detectedLabels.first} Found";
    }
    
    // 5. Generate description with real location
    String description = "Found item near ${locationResult.address}.";
    if (fullText.isNotEmpty) {
      description += "\n\nText detected on item:\n${fullText.length > 50 ? '${fullText.substring(0, 50)}...' : fullText}";
    }
    
    // 6. Simple Category Inference
    ItemCategory category = ItemCategory.other;
    final lowerLabels = detectedLabels.map((e) => e.toLowerCase()).toList();
    if (lowerLabels.contains('electronic') || lowerLabels.contains('phone') || lowerLabels.contains('laptop')) {
      category = ItemCategory.electronics;
    } else if (lowerLabels.contains('book') || lowerLabels.contains('notebook')) {
      category = ItemCategory.books;
    } else if (lowerLabels.contains('wallet') || lowerLabels.contains('bag')) {
      category = ItemCategory.accessories;
    } else if (lowerLabels.contains('card') || lowerLabels.contains('id')) {
      category = ItemCategory.idCards;
    }
    
    textRecognizer.close();
    imageLabeler.close();

    return {
      'title': title,
      'description': description,
      'tags': detectedLabels,
      'category': category,
      'location': locationResult.address,
      'latitude': locationResult.latitude,
      'longitude': locationResult.longitude,
    };
  }
}

final reFindAIServiceProvider = Provider<ReFindAIService>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return ReFindAIService(locationService);
});
