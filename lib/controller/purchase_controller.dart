import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
import '../services/commerce_service.dart';
import '../models/purchase_model.dart';

class PurchaseController with ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();
  final CommerceService _commerceService = CommerceService();

  List<PurchaseModel> _purchases = [];
  bool _isLoading = false;
  bool _isLoadMoreLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  static const int _limit = 15;

  final Map<String, String> _commerceNames = {};
  final Set<String> _loadingCommerceIds = {};

  List<PurchaseModel> get purchases => _purchases;
  bool get isLoading => _isLoading;
  bool get isLoadMoreLoading => _isLoadMoreLoading;
  bool get hasMore => _hasMore;
  Map<String, String> get commerceNames => _commerceNames;

  Future<void> loadInitialPurchases(String email) async {
    if (email.isEmpty) return;

    _isLoading = true;
    _skip = 0;
    _hasMore = true;
    _purchases = [];
    notifyListeners();

    try {
      final results = await _purchaseService.getPurchaseHistory(
        email: email,
        skip: _skip,
        limit: _limit,
      );
      _purchases = results;
      if (results.length < _limit) {
        _hasMore = false;
      }
    } catch (e) {
      print("Error loading initial purchases: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePurchases(String email) async {
    if (_isLoadMoreLoading || !_hasMore || _isLoading || email.isEmpty) return;

    _isLoadMoreLoading = true;
    notifyListeners();

    _skip = _purchases.length;

    try {
      final results = await _purchaseService.getPurchaseHistory(
        email: email,
        skip: _skip,
        limit: _limit,
      );

      _purchases.addAll(results);
      if (results.length < _limit) {
        _hasMore = false;
      }
    } catch (e) {
      print("Error loading more purchases: $e");
    } finally {
      _isLoadMoreLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommerceNameIfNeeded(String commerceId) async {
    if (commerceId.isEmpty ||
        _commerceNames.containsKey(commerceId) ||
        _loadingCommerceIds.contains(commerceId)) {
      return;
    }

    _loadingCommerceIds.add(commerceId);

    try {
      final commerce = await _commerceService.getCommerceById(commerceId);
      if (commerce != null && commerce.name.isNotEmpty) {
        _commerceNames[commerceId] = commerce.name;
        // Optionally update any purchase in memory that has this commerceId
        for (var p in _purchases) {
          if (p.commerceId == commerceId) {
            p.commerceName = commerce.name;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching commerce name for ID $commerceId: $e");
    } finally {
      _loadingCommerceIds.remove(commerceId);
    }
  }
}
