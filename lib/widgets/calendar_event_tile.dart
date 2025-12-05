import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';

class CalendarEventTile extends StatelessWidget {
  final calendar.Event event;

  const CalendarEventTile({super.key, required this.event});

  Color _getEventColor(String? colorId) {
    switch (colorId) {
      case '1': return const Color(0xFF7986CB); // Lavender
      case '2': return const Color(0xFF33B679); // Sage
      case '3': return const Color(0xFF8E24AA); // Grape
      case '4': return const Color(0xFFE67C73); // Flamingo
      case '5': return const Color(0xFFF6BF26); // Banana
      case '6': return const Color(0xFFF4511E); // Tangerine
      case '7': return const Color(0xFF039BE5); // Peacock
      case '8': return const Color(0xFF616161); // Graphite
      case '9': return const Color(0xFF3F51B5); // Blueberry
      case '10': return const Color(0xFF0B8043); // Basil
      case '11': return const Color(0xFFD50000); // Tomato
      default: return Colors.blue; // Default
    }
  }

  String _getEventTypeLabel(String? eventType) {
    if (eventType == null) return 'Event';
    switch (eventType) {
      case 'outOfOffice': return 'Out of Office';
      case 'focusTime': return 'Focus Time';
      case 'workingLocation': return 'Location';
      default: return 'Event';
    }
  }

  IconData _getEventTypeIcon(String? eventType) {
    switch (eventType) {
      case 'outOfOffice': return Icons.block;
      case 'focusTime': return Icons.headphones;
      case 'workingLocation': return Icons.location_on;
      default: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = event.start?.dateTime ?? event.start?.date;
    final end = event.end?.dateTime ?? event.end?.date;
    
    String timeString;
    if (event.start?.date != null) {
      timeString = 'All Day';
    } else if (start != null) {
      final startTime = DateFormat.jm().format(start.toLocal());
      final endTime = end != null ? DateFormat.jm().format(end.toLocal()) : '';
      timeString = '$startTime - $endTime';
    } else {
      timeString = 'TBD';
    }

    final eventColor = _getEventColor(event.colorId);
    final eventTypeLabel = _getEventTypeLabel(event.eventType);
    final eventIcon = _getEventTypeIcon(event.eventType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color strip
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: eventColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.summary ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: eventColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(eventIcon, size: 12, color: eventColor),
                              const SizedBox(width: 4),
                              Text(
                                eventTypeLabel,
                                style: TextStyle(
                                  color: eventColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          timeString,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
