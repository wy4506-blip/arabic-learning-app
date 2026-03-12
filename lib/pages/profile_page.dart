import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/progress_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfilePage extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const ProfilePage({super.key, required this.settings, required this.onSettingsChanged});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _streakDays = 0;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snapshot = await ProgressService.getSnapshot();
    final unlocked = await UnlockService.isUnlocked();
    if (!mounted) return;
    setState(() {
      _streakDays = snapshot.streakDays;
      _unlocked = unlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            SectionTitle(title: 'Profile', subtitle: '学习体验、提醒、购买与支持'),
            const SizedBox(height: 16),
            AppSurface(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: AppTheme.bgCardSoft, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.person_outline_rounded, color: AppTheme.accentMintDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('学习中', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('连续学习 $_streakDays 天', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingGroup(
              title: '学习体验',
              children: [
                _SettingRow(
                  title: '文本显示模式',
                  value: _textModeLabel(widget.settings.textMode),
                  onTap: () => _showTextModeSheet(context),
                ),
                _SettingRow(
                  title: '外观模式',
                  value: _themeLabel(widget.settings.themePreference),
                  onTap: () => _showThemeSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingGroup(
              title: '提醒',
              children: [
                _SwitchRow(
                  title: '学习提醒',
                  value: widget.settings.reminderEnabled,
                  subtitle: widget.settings.reminderTime,
                  onChanged: (value) => widget.onSettingsChanged(widget.settings.copyWith(reminderEnabled: value)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingGroup(
              title: '内容与购买',
              children: [
                _SettingRow(title: '当前内容包', value: _unlocked ? '已解锁' : '前 3 课免费', onTap: () {}),
                _SettingRow(title: '恢复购买', value: '保留入口', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTextModeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<ArabicTextMode>(
        title: '文本显示模式',
        current: widget.settings.textMode,
        options: ArabicTextMode.values,
        labelBuilder: _textModeLabel,
        onSelected: (value) => widget.onSettingsChanged(widget.settings.copyWith(textMode: value)),
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<AppThemePreference>(
        title: '外观模式',
        current: widget.settings.themePreference,
        options: AppThemePreference.values,
        labelBuilder: _themeLabel,
        onSelected: (value) => widget.onSettingsChanged(widget.settings.copyWith(themePreference: value)),
      ),
    );
  }

  String _textModeLabel(ArabicTextMode mode) {
    switch (mode) {
      case ArabicTextMode.withDiacritics:
        return '带音符';
      case ArabicTextMode.dual:
        return '双显示';
      case ArabicTextMode.withoutDiacritics:
        return '去音符';
    }
  }

  String _themeLabel(AppThemePreference pref) {
    switch (pref) {
      case AppThemePreference.system:
        return '跟随系统';
      case AppThemePreference.light:
        return '浅色';
      case AppThemePreference.dark:
        return '深色';
    }
  }
}

class _SettingGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;
  const _SettingRow({required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => onChanged(!value),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _OptionsSheet<T> extends StatelessWidget {
  final String title;
  final T current;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const _OptionsSheet({required this.title, required this.current, required this.options, required this.labelBuilder, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...options.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(labelBuilder(e)),
                  trailing: current == e ? const Icon(Icons.check_rounded, color: AppTheme.accentMintDark) : null,
                  onTap: () {
                    onSelected(e);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
