import 'package:flutter/material.dart';
import '../services/commerce_service.dart';
import '../models/commerce_model.dart';
import '../models/eix_comercial_model.dart';

class CommerceController with ChangeNotifier {
  final CommerceService _commerceService = CommerceService();

  List<CommerceModel> _commerces = [];
  bool _isLoading = false;
  bool _isLoadMoreLoading = false;
  bool _hasMore = false;
  String _searchQuery = '';
  String _selectedCategory = '';

  // Odoo specific filters state
  List<EixComercialModel> _eixosComercials = [];
  int? _selectedEixId;
  String _selectedDistrict = '';

  List<CommerceModel> get commerces => _commerces;
  bool get isLoading => _isLoading;
  bool get isLoadMoreLoading => _isLoadMoreLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Odoo specific getters
  List<EixComercialModel> get eixosComercials => _eixosComercials;
  int? get selectedEixId => _selectedEixId;
  String get selectedDistrict => _selectedDistrict;

  static const int _pageSize = 20;

  Future<void> searchCommerces({
    String? query,
    String? category,
    int? eixId,
    String? district,
  }) async {
    _isLoading = true;
    _hasMore = false;
    _isLoadMoreLoading = false;
    
    if (query != null) _searchQuery = query;
    if (category != null) _selectedCategory = category;
    if (eixId != null) _selectedEixId = eixId;
    if (district != null) _selectedDistrict = district;

    if (eixId == -1) _selectedEixId = null;

    _commerces = [];
    notifyListeners();

    try {
      final results = await _commerceService.searchCommerces(
        queryName: _searchQuery,
        eixComercialId: _selectedEixId,
        district: _selectedDistrict,
        category: _selectedCategory,
        skip: 0,
        limit: _pageSize,
      );
      _commerces = results;
      _hasMore = results.length == _pageSize;
    } catch (e) {
      print("Error in CommerceController searchCommerces: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCommerces() async {
    if (_isLoading || _isLoadMoreLoading || !_hasMore) return;

    _isLoadMoreLoading = true;
    notifyListeners();

    try {
      final results = await _commerceService.searchCommerces(
        queryName: _searchQuery,
        eixComercialId: _selectedEixId,
        district: _selectedDistrict,
        category: _selectedCategory,
        skip: _commerces.length,
        limit: _pageSize,
      );
      _commerces.addAll(results);
      _hasMore = results.length == _pageSize;
    } catch (e) {
      print("Error loading more commerces: $e");
    } finally {
      _isLoadMoreLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the list of commercial axes from Odoo.
  Future<void> fetchEixosComercials() async {
    try {
      final results = await _commerceService.getEixosComercials();
      _eixosComercials = results;
      notifyListeners();
    } catch (e) {
      print("Error fetching eixos: $e");
    }
  }

  void setCategoryAndSearch(String category) {
    _selectedCategory = category;
    _searchQuery = '';
    searchCommerces(category: category);
  }

  double _loyaltyPoints = 0.0;
  bool _isPointsLoading = false;

  double get loyaltyPoints => _loyaltyPoints;
  bool get isPointsLoading => _isPointsLoading;

  Future<void> fetchLoyaltyPoints({int? customerId, String? email}) async {
    _isPointsLoading = true;
    notifyListeners();
    try {
      final points = await _commerceService.getLoyaltyPoints(
        customerId: customerId,
        email: email,
      );
      _loyaltyPoints = points ?? 0.0;
    } catch (e) {
      print("Error in CommerceController fetchLoyaltyPoints: $e");
    } finally {
      _isPointsLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedEixId = null;
    _selectedDistrict = '';
    searchCommerces();
  }
}
