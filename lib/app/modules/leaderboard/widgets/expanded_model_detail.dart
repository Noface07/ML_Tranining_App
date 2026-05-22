import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/model/leaderboard_entry_model.dart';
import 'dataset_chip.dart';

class ExpandedModelDetail extends StatelessWidget {
  final LeaderboardEntryModel entry;

  const ExpandedModelDetail({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: ClipRect(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.expandedRowBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: _MetricsTabs(entry: entry),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Data holder for a named section within a grouped tab
// ---------------------------------------------------------------------------

class _SectionData {
  final String title;
  final dynamic value;
  const _SectionData({required this.title, required this.value});
}

// ---------------------------------------------------------------------------
// Tab-based metrics view  (5 tabs max)
// ---------------------------------------------------------------------------

class _MetricsTabs extends StatefulWidget {
  final LeaderboardEntryModel entry;
  const _MetricsTabs({required this.entry});

  @override
  State<_MetricsTabs> createState() => _MetricsTabsState();
}

class _MetricsTabsState extends State<_MetricsTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<_TabDef> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_TabDef> _buildTabs() {
    final tabs = <_TabDef>[];

    // ── 1. Overview ─────────────────────────────────────────────────────────
    tabs.add(_TabDef(
      label: 'Overview',
      builder: () => _OverviewTabContent(entry: widget.entry),
    ));

    // ── 2. Hyperparameters (right after Overview) ────────────────────────────
    if (widget.entry.hparamsUsed.isNotEmpty) {
      tabs.add(_TabDef(
        label: 'Hyperparameters',
        builder: () => _HyperparamsTabContent(entry: widget.entry),
      ));
    }

    // ── 3. Metrics (group all Map-valued keys except imp) ────────────────────
    final metricSections = <_SectionData>[];
    if (widget.entry.metrics != null) {
      for (final metric in widget.entry.metrics!.entries) {
        final keyLower = metric.key.toLowerCase().replaceAll('_', '');
        if (keyLower == 'imp') continue;
        if (metric.value is! Map) continue;

        if (keyLower == 'generalizationmetrics') {
          final filtered = Map.from(metric.value as Map)
            ..removeWhere((k, v) {
              final s = k.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
              return s == 'isunderfit';
            });
          if (filtered.isNotEmpty) {
            metricSections.add(_SectionData(
              title: _labelFromKey(metric.key),
              value: filtered,
            ));
          }
        } else {
          metricSections.add(_SectionData(
            title: _labelFromKey(metric.key),
            value: metric.value,
          ));
        }
      }
    }
    if (metricSections.isNotEmpty) {
      tabs.add(_TabDef(
        label: 'Metrics',
        builder: () => _GroupedTabContent(sections: metricSections),
      ));
    }

    // ── 4. Model Analysis (deployment_health + model_fit_analysis from imp) ──
    final modelSections = <_SectionData>[];
    if (widget.entry.metrics != null &&
        widget.entry.metrics!['imp'] is Map) {
      final impMap = widget.entry.metrics!['imp'] as Map;
      for (final sub in impMap.entries) {
        final kl = sub.key.toString().toLowerCase().replaceAll('_', '');
        if (kl == 'deploymenthealth' || kl == 'modelfitanalysis') {
          modelSections.add(_SectionData(
            title: _labelFromKey(sub.key.toString()),
            value: sub.value,
          ));
        }
      }
    }
    if (modelSections.isNotEmpty) {
      tabs.add(_TabDef(
        label: 'Model Analysis',
        builder: () => _GroupedTabContent(sections: modelSections),
      ));
    }

    // ── 5. Feature Importance ────────────────────────────────────────────────
    if (widget.entry.featureImportance != null &&
        widget.entry.featureImportance!.isNotEmpty) {
      tabs.add(_TabDef(
        label: 'Feature Importance',
        builder: () => _FeatureImportanceTabContent(entry: widget.entry),
      ));
    }

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.tableBorder, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            tabs: _tabs
                .map((t) => Tab(text: t.label, height: 40))
                .toList(),
          ),
        ),
        // Tab content
        _AnimatedTabContent(tabController: _tabController, tabs: _tabs),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Animated tab content switcher
// ---------------------------------------------------------------------------

class _AnimatedTabContent extends StatefulWidget {
  final TabController tabController;
  final List<_TabDef> tabs;
  const _AnimatedTabContent(
      {required this.tabController, required this.tabs});

  @override
  State<_AnimatedTabContent> createState() => _AnimatedTabContentState();
}

class _AnimatedTabContentState extends State<_AnimatedTabContent> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabController.index;
    widget.tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!widget.tabController.indexIsChanging) return;
    setState(() => _currentIndex = widget.tabController.index);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: widget.tabs[_currentIndex].builder(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab definition
// ---------------------------------------------------------------------------

class _TabDef {
  final String label;
  final Widget Function() builder;
  const _TabDef({required this.label, required this.builder});
}

// ---------------------------------------------------------------------------
// Overview tab
// ---------------------------------------------------------------------------

class _OverviewTabContent extends StatelessWidget {
  final LeaderboardEntryModel entry;
  const _OverviewTabContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final scalarMetrics = <Widget>[];
    if (entry.metrics == null || entry.metrics!.isEmpty) {
      scalarMetrics.addAll([
        const MetricCell(label: 'Precision', value: '—'),
        const MetricCell(label: 'Accuracy', value: '—'),
        const MetricCell(label: 'Recall', value: '—'),
        const MetricCell(label: 'F1', value: '—'),
      ]);
    } else {
      for (final metric in entry.metrics!.entries) {
        final keyLower = metric.key.toLowerCase().replaceAll('_', '');
        if (keyLower == 'imp') continue;
        if (metric.value is Map) continue;
        scalarMetrics.add(MetricCell(
          label: _labelFromKey(metric.key),
          value: _formatValue(metric.value),
        ));
      }
    }

    final metricsCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scalarMetrics,
    );

    final infoCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.trainingDurationSeconds != null)
          MetricCell(
            label: 'Duration',
            value: '${entry.trainingDurationSeconds!.toStringAsFixed(2)}s',
          ),
        if (entry.tagsUsed.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Tags',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.tagsUsed.map((t) => DatasetChip(fileName: t)).toList(),
          ),
        ],
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          metricsCol,
          if (entry.trainingDurationSeconds != null || entry.tagsUsed.isNotEmpty) ...[
            const SizedBox(height: 16),
            infoCol,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: metricsCol),
        const SizedBox(width: 32),
        Expanded(child: infoCol),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped tab: sections displayed in 2 columns (desktop) / 1 column (mobile)
// ---------------------------------------------------------------------------

class _GroupedTabContent extends StatelessWidget {
  final List<_SectionData> sections;
  const _GroupedTabContent({required this.sections});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile || sections.length == 1) {
      // Single column
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _SectionBlock(section: sections[i]),
          ],
        ],
      );
    }

    // Split sections into two halves for a 2-column layout
    final mid = (sections.length / 2).ceil();
    final leftSections = sections.sublist(0, mid);
    final rightSections = sections.sublist(mid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < leftSections.length; i++) ...[
                if (i > 0) const SizedBox(height: 20),
                _SectionBlock(section: leftSections[i]),
              ],
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < rightSections.length; i++) ...[
                if (i > 0) const SizedBox(height: 20),
                _SectionBlock(section: rightSections[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final _SectionData section;
  const _SectionBlock({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          section.title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        // Section rows
        ..._buildRows(section.value),
      ],
    );
  }

  List<Widget> _buildRows(dynamic value) {
    if (value is! Map) {
      return [MetricCell(label: section.title, value: _formatValue(value))];
    }
    final rows = <Widget>[];
    for (final e in value.entries) {
      if (e.value is Map) {
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            _labelFromKey(e.key.toString()),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ));
        rows.addAll(_buildNestedRows(e.value as Map));
      } else {
        rows.add(MetricCell(
          label: _labelFromKey(e.key.toString()),
          value: _formatValue(e.value),
        ));
      }
    }
    return rows;
  }

  List<Widget> _buildNestedRows(Map map) {
    return map.entries.map<Widget>((e) {
      return MetricCell(
        label: _labelFromKey(e.key.toString()),
        value: _formatValue(e.value),
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Feature Importance tab
// ---------------------------------------------------------------------------

class _FeatureImportanceTabContent extends StatelessWidget {
  final LeaderboardEntryModel entry;
  const _FeatureImportanceTabContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entry.featureImportance!.entries.map((fi) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.tableBorder),
          ),
          child: Text(
            '${fi.key.replaceAll('_', ' ')}: ${_formatValue(fi.value)}',
            style: AppTextStyles.paramChip,
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Hyperparameters tab
// ---------------------------------------------------------------------------

class _HyperparamsTabContent extends StatelessWidget {
  final LeaderboardEntryModel entry;
  const _HyperparamsTabContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entry.hparamsUsed.entries.map((param) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.tableBorder),
          ),
          child: Text(
            '${param.key.replaceAll('_', ' ')}: ${_formatValue(param.value)}',
            style: AppTextStyles.paramChip,
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _labelFromKey(String key) {
  return key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) =>
          w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '')
      .join(' ');
}

String _formatValue(dynamic val) {
  if (val is double) {
    return val.toStringAsFixed(4);
  } else if (val is Map) {
    final entries = val.entries
        .map((e) =>
            '${e.key.toString().replaceAll('_', ' ')}: ${_formatValue(e.value)}')
        .join(', ');
    return '{$entries}';
  } else if (val is List) {
    return '[${val.map((e) => _formatValue(e)).join(', ')}]';
  }
  return val.toString().replaceAll('_', ' ');
}

// ---------------------------------------------------------------------------
// MetricCell — fixed label column so value is always close to label
// ---------------------------------------------------------------------------

class MetricCell extends StatelessWidget {
  final String label;
  final String value;

  const MetricCell({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed-width label column — keeps value snug regardless of container width
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
