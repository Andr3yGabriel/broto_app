import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _horarioRelativo(DateTime ts) {
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    final dia = DateTime(ts.year, ts.month, ts.day);
    final hora =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    if (dia == hoje) return 'hoje às $hora';
    if (dia == hoje.subtract(const Duration(days: 1))) {
      return 'ontem às $hora';
    }
    return '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')} às $hora';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _carregarLog(),
          builder: (context, snap) {
            final items = snap.data ?? [];
            return CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'notificações',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'nenhuma notificação ainda',
                        style: TextStyle(color: AppColors.soft),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = items[i];
                          final ts =
                              DateTime.tryParse(item['timestamp'] ?? '') ??
                                  DateTime.now();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.only(top: 5, right: 10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? '',
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if ((item['body'] ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item['body'] ?? '',
                                          style: const TextStyle(
                                            color: AppColors.soft,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        _horarioRelativo(ts),
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _carregarLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notification_log') ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    return list.reversed
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
