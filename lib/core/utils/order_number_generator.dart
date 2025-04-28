import 'dart:math';

class OrderNumberGenerator {
  static String generateUniqueNumber() {
    final random = Random();
    
    // Get current timestamp and take only the last 6 digits
    final timestamp = DateTime.now().millisecondsSinceEpoch % 1000000;
    
    // Generate a random 4-digit number
    final randomNumber = random.nextInt(10000).toString().padLeft(4, '0');
    
    // Combine to create a 10-digit number
    return '$timestamp$randomNumber';
  }
}