import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/nfc_record.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/nfc_result_card.dart';
import '../widgets/pulse_animation.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final NfcService _nfcService = NfcService(
    // TODO: Điền accessToken và tokenId từ server VNPT
    // accessToken: 'Bearer ...',
    // tokenId: '...',
    // baseUrl: 'https://...',
  );
  final StorageService _storageService = StorageService();

  bool _isScanning = false;
  NfcRecord? _lastRecord;
  dynamic _rawData;
  String? _errorMessage;

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final result = await _nfcService.startMRZAndNFC();

      if (result != null) {
        HapticFeedback.mediumImpact();
        
        NfcRecord? record;
        if (result is Map) {
          try {
            record = NfcRecord.fromVNPTResult(result);
            await _storageService.saveRecord(record);
          } catch (e) {
            log('Error parsing NfcRecord: $e');
          }
        }

        if (mounted) {
          setState(() {
            _rawData = result;
            _lastRecord = record;
            _isScanning = false;
          });
        }
      } else {
        // User cancelled
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    } on NfcException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi: $e';
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // NFC Scan Area
          PulseAnimation(
            isScanning: _isScanning,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.credit_card,
                  size: 48,
                  color: _isScanning
                      ? AppColors.accentCyan
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'CCCD',
                  style: TextStyle(
                    color: _isScanning
                        ? AppColors.accentCyan
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isScanning
                  ? 'Đang mở SDK quét MRZ...'
                  : _lastRecord != null
                      ? 'Đọc thẻ CCCD thành công!'
                      : 'Nhấn nút để quét CCCD',
              key: ValueKey(_isScanning
                  ? 'scanning'
                  : _lastRecord != null
                      ? 'success'
                      : 'idle'),
              style: TextStyle(
                color: _isScanning
                    ? AppColors.accentCyan
                    : _lastRecord != null
                        ? AppColors.success
                        : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Sub description
          Text(
            'Quét mã MRZ → Đọc chip NFC trên CCCD',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.error.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Scan button
          GestureDetector(
            onTap: _isScanning ? null : _startScan,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: _isScanning
                    ? LinearGradient(
                        colors: [
                          AppColors.textMuted.withValues(alpha: 0.3),
                          AppColors.textMuted.withValues(alpha: 0.2),
                        ],
                      )
                    : AppColors.primaryGradient,
                boxShadow: _isScanning
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isScanning ? Icons.hourglass_top : Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isScanning ? 'Đang quét...' : 'Quét CCCD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Result card
          if (_lastRecord != null)
            NfcResultCard(record: _lastRecord!),

          const SizedBox(height: 32),

          // Raw data debug view
          if (_rawData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Raw SDK Data',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    const JsonEncoder.withIndent('  ').convert(_rawData),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
