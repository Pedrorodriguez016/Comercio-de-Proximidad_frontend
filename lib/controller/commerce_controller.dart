import 'package:flutter/material.dart';
import '../services/commerce_service.dart';
import '../utils/token_manager.dart';

class CommerceController with ChangeNotifier {
  final CommerceService _commerceService = CommerceService();
  
  List<dynamic> _commerces = [];
  bool _isLoading = false;
  bool _isLoadMoreLoading = false;
  bool _hasMore = true;
  String _searchQuery = '';
  String _selectedCategory = '';
  static const int _limit = 15;

  List<dynamic> get commerces => _commerces;
  bool get isLoading => _isLoading;
  bool get isLoadMoreLoading => _isLoadMoreLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Future<void> searchCommerces({String? query, String? category}) async {
    _isLoading = true;
    _hasMore = true;
    _isLoadMoreLoading = false;
    _searchQuery = query ?? _searchQuery;
    _selectedCategory = category ?? _selectedCategory;
    _commerces = []; // Limpiamos para nueva búsqueda
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
        skip: 0,
        limit: _limit,
      );
      _commerces = results;
      if (results.length < _limit) {
        _hasMore = false;
      }
    } catch (e) {
      print("Error in CommerceController: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCommerces() async {
    if (_isLoadMoreLoading || _isLoading || !_hasMore) return;

    _isLoadMoreLoading = true;
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
        skip: _commerces.length,
        limit: _limit,
      );
      
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _commerces.addAll(results);
        if (results.length < _limit) {
          _hasMore = false;
        }
      }
    } catch (e) {
      print("Error loading more commerces: $e");
    } finally {
      _isLoadMoreLoading = false;
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
