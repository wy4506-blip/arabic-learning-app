import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../services/v2_learning_snapshot_service.dart';
import '../services/v2_review_flow_service.dart';
import '../theme/app_theme.dart';
import 'review_session_page.dart';

class V2ReviewEntryPage extends StatefulWidget {
  final AppSettings settings;
  final List<V2DueReviewItem> dueReviewItems;

  const V2ReviewEntryPage({
    super.key,
    required this.settings,
    required this.dueReviewItems,
  });

  @override
  State<V2ReviewEntryPage> createState() => _V2ReviewEntryPageState();
}

class _V2ReviewEntryPageState extends State<V2ReviewEntryPage> {
  bool _launchStarted = false;
  bool _launchFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchReviewFlow();
    });
  }

  Future<void> _launchReviewFlow() async {
    if (_launchStarted) {
      return;
    }
    _launchStarted = true;

    final session = await V2ReviewFlowService.createPilotReviewSession(
      settings: widget.settings,
      dueReviewItems: widget.dueReviewItems,
    );
    if (!mounted) {
      return;
    }
    if (session == null) {
      setState(() => _launchFailed = true);
      Navigator.of(context).pop(false);
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(result == true);
  }

  @override
  Widget build(BuildContext context) {
    final dueCount = widget.dueReviewItems.length;
    final dueCountText = localizedText(
      context,
      zh: '$dueCount 个到期或薄弱项',
      en: dueCount == 1 ? '1 due or weak item' : '$dueCount due or weak items',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizedText(
            context,
            zh: '样板复习',
            en: 'Pilot Review',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppTheme.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedText(
                      context,
                      zh: '先处理这轮挡住主线的复习项',
                      en: 'Clear the review items blocking the mainline',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizedText(
                      context,
                      zh: '已为你准备 $dueCountText，完成后会返回首页并重算推荐。',
                      en: dueCount == 1
                          ? '$dueCountText is ready. After review, home will refresh the next recommendation.'
                          : '$dueCountText are ready. After review, home will refresh the next recommendation.',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (_launchFailed) ...[
                    Text(
                      localizedText(
                        context,
                        zh: '当前没有可启动的样板复习，返回首页后会重新计算。',
                        en: 'No pilot review session could be started right now. Return home to refresh the recommendation.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        localizedText(
                          context,
                          zh: '返回首页',
                          en: 'Back Home',
                        ),
                      ),
                    ),
                  ] else ...[
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
