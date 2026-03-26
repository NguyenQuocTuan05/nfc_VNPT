import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/nfc_record.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class NfcResultCard extends StatelessWidget {
  final NfcRecord record;
  final bool showTimestamp;

  const NfcResultCard({
    super.key,
    required this.record,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.darkCard.withValues(alpha: 0.7),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.hasCCCDData
                          ? 'Thông tin CCCD'
                          : 'Chi tiết thẻ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (showTimestamp)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.success.withValues(alpha: 0.15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Thành công',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),

              // CCCD info fields
              if (record.fullName != null)
                _buildInfoRow('Họ và tên', record.fullName!, Icons.person_outline),
              if (record.documentNumber != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Số CCCD', record.documentNumber!, Icons.badge_outlined),
              ],
              if (record.dateOfBirth != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Ngày sinh', record.dateOfBirth!, Icons.cake_outlined),
              ],
              if (record.gender != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Giới tính', record.gender!, Icons.wc_outlined),
              ],
              if (record.nationality != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Quốc tịch', record.nationality!, Icons.flag_outlined),
              ],
              if (record.placeOfOrigin != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Quê quán',
                  record.placeOfOrigin!,
                  Icons.home_outlined,
                  isMultiline: true,
                ),
              ],
              if (record.placeOfResidence != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Nơi thường trú',
                  record.placeOfResidence!,
                  Icons.location_on_outlined,
                  isMultiline: true,
                ),
              ],
              if (record.personalNumber != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Số định danh', record.personalNumber!, Icons.fingerprint),
              ],
              if (record.issueDate != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Ngày cấp', record.issueDate!, Icons.calendar_today_outlined),
              ],
              if (record.expiryDate != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Ngày hết hạn', record.expiryDate!, Icons.event_outlined),
              ],
              if (record.issuingAuthority != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Nơi cấp',
                  record.issuingAuthority!,
                  Icons.account_balance_outlined,
                  isMultiline: true,
                ),
              ],

              // Fallback: raw tag info if no CCCD data
              if (!record.hasCCCDData) ...[
                _buildInfoRow('Tag ID', record.tagId, Icons.fingerprint),
                const SizedBox(height: 12),
                _buildInfoRow('Loại thẻ', record.tagType, Icons.category_outlined),
              ],

              if (showTimestamp) ...[
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('HH:mm:ss - dd/MM/yyyy')
                          .format(record.timestamp),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkCardBorder.withValues(alpha: 0.0),
            AppColors.darkCardBorder,
            AppColors.darkCardBorder.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
