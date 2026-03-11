import 'package:flutter/material.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';

class UnlockPage extends StatelessWidget {
  const UnlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTopButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '解锁全部课程',
                      style: text.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEAF8F3),
                      Color(0xFFDFF2EB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أبا أبا', style: text.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      '一次性解锁全部后续课程内容。',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_open_rounded,
                            color: AppTheme.deepAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '前三课免费，后续一次性解锁 ¥10',
                            style: text.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('解锁后可获得', style: text.titleLarge),
              const SizedBox(height: 14),
              _buildBenefitCard(context, '全部课程开放'),
              _buildBenefitCard(context, '锁定提示自动消失'),
              _buildBenefitCard(context, '首页不再显示解锁入口'),
              _buildBenefitCard(context, '学习路径恢复为完整版本'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.deepAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    await UnlockService.unlockAllCourses();
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('立即解锁（模拟）'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '当前为本地模拟解锁，后续可接正式支付。',
                  style: text.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryText,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(BuildContext context, String textValue) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE8F5F0),
            child: Icon(
              Icons.check_rounded,
              color: AppTheme.deepAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              textValue,
              style: text.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
