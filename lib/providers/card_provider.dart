import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CardData {
  final String id;
  final String userId;
  final String? transactionId;
  final String cardId;
  final String cardName;
  final String imageUrl;
  final String setId;
  final String acquiredAt;

  CardData({
    required this.id,
    required this.userId,
    required this.transactionId,
    required this.cardId,
    required this.cardName,
    required this.imageUrl,
    required this.setId,
    required this.acquiredAt,
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      transactionId: json['transaction_id'],
      cardId: json['card_id'] ?? '',
      cardName: json['card_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      setId: json['set_id'] ?? '',
      acquiredAt: json['acquired_at'] ?? '',
    );
  }
}

class PurchaseResult {
  final List<CardData> cardsObtained;
  final String message;
  final String packName;
  final int remainingBalance;
  final String transactionId;

  PurchaseResult({
    required this.cardsObtained,
    required this.message,
    required this.packName,
    required this.remainingBalance,
    required this.transactionId,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    final cardsList = (json['kartu_didapat'] as List<dynamic>?)
        ?.map((card) => CardData.fromJson(card as Map<String, dynamic>))
        .toList() ?? [];
    
    return PurchaseResult(
      cardsObtained: cardsList,
      message: json['message'] ?? '',
      packName: json['pack_dibeli'] ?? '',
      remainingBalance: json['sisa_saldo'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
    );
  }
}

class CardProvider extends ChangeNotifier {
  List<CardData> _myCards = [];
  bool _isLoading = false;
  String? _errorMessage;
  PurchaseResult? _lastPurchaseResult;

  List<CardData> get myCards => _myCards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PurchaseResult? get lastPurchaseResult => _lastPurchaseResult;

  /// Fetch user's card collection from API
  Future<void> fetchMyCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
      }

      final response = await http.get(
        Uri.parse('https://api-tcg-backend.vercel.app/api/pokemon/my-cards'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        
        if (decodedData is Map<String, dynamic>) {
          final cardsList = (decodedData['data'] as List<dynamic>?)
              ?.map((card) => CardData.fromJson(card as Map<String, dynamic>))
              .toList() ?? [];
          
          _myCards = cardsList;
        } else {
          throw Exception('Format response tidak sesuai');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah habis (401). Silakan login kembali.');
      } else {
        throw Exception('Gagal memuat koleksi kartu: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[CardProvider] Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buy a Pokemon pack/set
  Future<bool> buyPack(String setId) async {
    _isLoading = true;
    _errorMessage = null;
    _lastPurchaseResult = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
      }

      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/store/buy-pack'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'set_id': setId}),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        _lastPurchaseResult = PurchaseResult.fromJson(decodedData as Map<String, dynamic>);
        
        // Refresh card collection
        await fetchMyCards();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 400) {
        final dynamic decodedData = json.decode(response.body);
        throw Exception(decodedData['message'] ?? 'Saldo tidak cukup untuk membeli pack ini');
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah habis (401). Silakan login kembali.');
      } else {
        throw Exception('Gagal membeli pack: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[CardProvider] Buy Pack Error: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear the last purchase result
  void clearPurchaseResult() {
    _lastPurchaseResult = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
