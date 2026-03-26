import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoScan = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        // App Info Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.nfc,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NFC Reader',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'VNPT - Phiên bản 1.0.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Settings section title
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Cài đặt chung',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Settings items
        _buildSettingsTile(
          icon: Icons.volume_up_outlined,
          iconColor: AppColors.primaryBlue,
          title: 'Âm thanh',
          subtitle: 'Phát âm thanh khi quét xong',
          trailing: Switch.adaptive(
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
            activeTrackColor: AppColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 12),

        _buildSettingsTile(
          icon: Icons.vibration,
          iconColor: AppColors.primaryPurple,
          title: 'Rung',
          subtitle: 'Rung khi phát hiện thẻ NFC',
          trailing: Switch.adaptive(
            value: _vibrationEnabled,
            onChanged: (v) => setState(() => _vibrationEnabled = v),
            activeTrackColor: AppColors.primaryPurple,
          ),
        ),

        const SizedBox(height: 12),

        _buildSettingsTile(
          icon: Icons.autorenew,
          iconColor: AppColors.accentCyan,
          title: 'Tự động quét',
          subtitle: 'Tự động bắt đầu quét khi mở ứng dụng',
          trailing: Switch.adaptive(
            value: _autoScan,
            onChanged: (v) => setState(() => _autoScan = v),
            activeTrackColor: AppColors.accentCyan,
          ),
        ),

        const SizedBox(height: 28),

        // About section
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Thông tin',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        _buildSettingsTile(
          icon: Icons.info_outline,
          iconColor: AppColors.success,
          title: 'Phiên bản',
          subtitle: '1.0.0',
        ),

        const SizedBox(height: 12),

        _buildSettingsTile(
          icon: Icons.code,
          iconColor: AppColors.warning,
          title: 'Phát triển bởi',
          subtitle: 'VNPT Technology',
        ),

        const SizedBox(height: 12),

        _buildSettingsTile(
          icon: Icons.shield_outlined,
          iconColor: AppColors.primaryBlue,
          title: 'Chính sách bảo mật',
          subtitle: 'Xem chính sách bảo mật',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.darkCard,
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: iconColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
