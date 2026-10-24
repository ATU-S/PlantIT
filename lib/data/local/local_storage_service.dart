import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm_model.dart';
import '../models/gamification_model.dart';

class LocalStorageService {
  static const String _keyFarms = 'plantit_farms_v1';
  static const String _keyActiveFarmId = 'plantit_active_farm_id_v1';
  static const String _keyGamification = 'plantit_gamification_v1';
  static const String _keyGeminiApiKey = 'plantit_gemini_api_key';
  static const String _keyOnboardingProfile = 'plantit_onboarding_profile_v1';
  static const String _keyOnboardingCompleted = 'plantit_onboarding_completed_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Farm Operations
  List<Farm> getFarms() {
    final raw = _prefs.getString(_keyFarms);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((f) => Farm.fromJson(f as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFarms(List<Farm> farms) async {
    final raw = jsonEncode(farms.map((f) => f.toJson()).toList());
    await _prefs.setString(_keyFarms, raw);
  }

  String? getActiveFarmId() {
    return _prefs.getString(_keyActiveFarmId);
  }

  Future<void> setActiveFarmId(String farmId) async {
    await _prefs.setString(_keyActiveFarmId, farmId);
  }

  // Gamification Operations
  UserGamification getGamification() {
    final raw = _prefs.getString(_keyGamification);
    if (raw == null || raw.isEmpty) {
      return UserGamification(
        userId: 'user_local_1',
        username: 'Kerala Green Thumb',
        totalPoints: 20, // Initial welcome bonus
        currentStreak: 1,
        bestStreak: 1,
        lastActiveDate: DateTime.now(),
        unlockedBadgeIds: [],
      );
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return UserGamification.fromJson(decoded);
    } catch (_) {
      return UserGamification(
        userId: 'user_local_1',
        username: 'Kerala Green Thumb',
      );
    }
  }

  Future<void> saveGamification(UserGamification gamification) async {
    final raw = jsonEncode(gamification.toJson());
    await _prefs.setString(_keyGamification, raw);
  }

  // Onboarding profile
  bool hasCompletedOnboarding() => _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Map<String, String> getBeginnerProfile() {
    final raw = _prefs.getString(_keyOnboardingProfile);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
    } catch (_) {
      return {};
    }
    return {};
  }

  Future<void> saveBeginnerProfile(Map<String, String> profile) async {
    await _prefs.setString(_keyOnboardingProfile, jsonEncode(profile));
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  // API Key storage
  String? getGeminiApiKey() => _prefs.getString(_keyGeminiApiKey);
  Future<void> saveGeminiApiKey(String key) => _prefs.setString(_keyGeminiApiKey, key);
}
