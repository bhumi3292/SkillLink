import 'package:flutter/material.dart';

class BookingTimeline extends StatelessWidget {
  final List<dynamic>? timeline;
  const BookingTimeline({super.key, this.timeline});

  @override
  Widget build(BuildContext context) {
    final items = timeline ?? [];
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.schedule, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No timeline events yet',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort by timestamp asc
    items.sort((a, b) {
      DateTime ta =
          DateTime.tryParse(a['timestamp']?.toString() ?? '') ??
          DateTime.tryParse(a['timestamp'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(
            (a['timestamp'] is int) ? a['timestamp'] : 0,
          );
      DateTime tb =
          DateTime.tryParse(b['timestamp']?.toString() ?? '') ??
          DateTime.tryParse(b['timestamp'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(
            (b['timestamp'] is int) ? b['timestamp'] : 0,
          );
      return ta.compareTo(tb);
    });

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final it = items[index];
        final status = (it['status'] ?? it['event'] ?? '').toString();
        final timestampRaw = it['timestamp'];
        DateTime ts;
        if (timestampRaw == null) {
          ts = DateTime.now();
        } else if (timestampRaw is String)
          ts = DateTime.tryParse(timestampRaw) ?? DateTime.now();
        else if (timestampRaw is int)
          ts = DateTime.fromMillisecondsSinceEpoch(timestampRaw);
        else if (timestampRaw is DateTime)
          ts = timestampRaw;
        else
          ts = DateTime.now();

        final actorName =
            it['actorRole'] ?? it['actorName'] ?? it['actor'] ?? '';
        final reason = it['reason'] ?? '';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(status),
                  ),
                ),
                if (index != items.length - 1)
                  Container(width: 2, height: 48, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _prettyStatus(status),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTimestamp(ts)} • ${actorName.toString()}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  if (reason != null && reason.toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      reason.toString(),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime t) {
    return '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _prettyStatus(String s) {
    if (s.isEmpty) return 'Event';
    return s[0].toUpperCase() + s.substring(1);
  }

  Color _statusColor(String s) {
    final k = s.toLowerCase();
    if (k.contains('pending')) return Colors.orange;
    if (k.contains('accepted') || k.contains('confirmed')) return Colors.blue;
    if (k.contains('inprogress')) return Colors.purple;
    if (k.contains('completed')) return Colors.green;
    if (k.contains('cancel')) return Colors.red;
    if (k.contains('rejected')) return Colors.red.shade700;
    return Colors.grey;
  }
}
