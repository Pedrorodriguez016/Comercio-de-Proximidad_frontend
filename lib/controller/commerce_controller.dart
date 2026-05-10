import 'package:flutter/material.dart';
import '../services/commerce_service.dart';
import '../utils/token_manager.dart';

class CommerceController with ChangeNotifier {
  final CommerceService _commerceService = CommerceService();
  
  List<dynamic> _commerces = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '';

  List<dynamic> get commerces => _commerces;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Future<void> searchCommerces({String? query, String? category}) async {
    _isLoading = true;
    _searchQuery = query ?? _searchQuery;
    _selectedCategory = category ?? _selectedCategory;
    notifyListeners();

    try {
      final token = await TokenManager.getAccessToken();
      if (token == null) {
        print("Error: Token no encontrado");
        return;
      }

      final results = await _commerceService.searchCommerces(
        queryName: _searchQuery,
        type: _selectedCategory,
        token: token,
      );
      _commerces = results;
    } catch (e) {
      print("Error in CommerceController: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategoryAndSearch(String category) {
    _selectedCategory = category;
    _searchQuery = ''; // Limpiamos texto si buscamos por categoría
    searchCommerces();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    searchCommerces();
  }
}
