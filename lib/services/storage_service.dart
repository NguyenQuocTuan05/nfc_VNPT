import 'package:shared_preferences/shared_preferences.dart';
import '../models/nfc_record.dart';

class StorageService {
  static const String _historyKey = 'nfc_history';
  static const int _maxHistory = 100;

  /// Save an NFC record to history
  Future<void> saveRecord(NfcRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.insert(0, record.toJsonString());

    // Keep only the latest records
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }

    await prefs.setStringList(_historyKey, history);
  }

  /// Get all NFC records from history
  Future<List<NfcRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    return history.map((s) => NfcRecord.fromJsonString(s)).toList();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Delete a single record by index
  Future<void> deleteRecord(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await prefs.setStringList(_historyKey, history);
    }
  }
}
