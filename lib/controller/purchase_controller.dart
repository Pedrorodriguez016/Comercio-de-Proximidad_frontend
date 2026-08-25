import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
import '../services/commerce_service.dart';
import '../models/purchase_model.dart';

enum DateFilterType { all, last7Days, thisMonth, custom }

class PurchaseController with ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();
  final CommerceService _commerceService = CommerceService();

  List<PurchaseModel> _purchases = [];
  bool _isLoading = false;
  bool _isLoadMoreLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  static const int _limit = 15;

  DateFilterType _selectedFilter = DateFilterType.all;
  DateTime? _startDate;
  DateTime? _endDate;

  final Map<String, String> _commerceNames = {};
  final Set<String> _loadingCommerceIds = {};

  List<PurchaseModel> get purchases => _purchases;
  bool get isLoading => _isLoading;
  bool get isLoadMoreLoading => _isLoadMoreLoading;
  bool get hasMore => _hasMore;
  DateFilterType get selectedFilter => _selectedFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
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
        startDate: _startDate,
        endDate: _endDate,
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
        startDate: _startDate,
        endDate: _endDate,
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

  void setFilter(DateFilterType filter, String email, {DateTime? customStart, DateTime? customEnd}) {
    _selectedFilter = filter;
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.all:
        _startDate = null;
        _endDate = null;
        break;
      case DateFilterType.last7Days:
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case DateFilterType.thisMonth:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case DateFilterType.custom:
        _startDate = customStart;
        _endDate = customEnd;
        break;
    }

    loadInitialPurchases(email);
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
