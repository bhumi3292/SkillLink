import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';

// Import your ApiEndpoints file
import '../../../../app/constant/api_endpoints.dart';

class workerManageAvailability extends StatefulWidget {
  final String propertyId;
  const workerManageAvailability({super.key, required this.propertyId});

  @override
  State<workerManageAvailability> createState() =>
      _workerManageAvailabilityState();
}

class _workerManageAvailabilityState extends State<workerManageAvailability> {
  DateTime? _selectedDate;
  final TextEditingController _slotController = TextEditingController();
  List<String> _slots = [];
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _availabilitiesMap = {};
  final TokenSharedPrefs _tokenSharedPrefs = TokenSharedPrefs(
    sharedPreferences: serviceLocator(),
  );

  String _normalizeDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(d);
  }

  Future<String?> _getToken() async {
    final tokenEither = await _tokenSharedPrefs.getToken();
    return tokenEither.fold((l) => null, (r) => r);
  }

  @override
  void initState() {
    super.initState();
    _fetchworkerAvailabilities();
  }

  Future<void> _fetchworkerAvailabilities() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to manage availability.';
          _loading = false;
        });
        return;
      }

      // Using ApiEndpoints.baseUrl for fetching
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}calendar/worker/availabilities',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final availabilities =
          response.data['availabilities'] as List? ??
          []; // Safely cast to List and provide empty list if null
      final map = <String, List<String>>{};

      for (var avail in availabilities) {
        // Safely access 'property' and then '_id'
        final propertyData = avail['property'] as Map<String, dynamic>?;
        if (propertyData != null && propertyData['_id'] == widget.propertyId) {
          final date =
              avail['date'] as String?; // date can be null from backend too
          final timeSlots = List<String>.from(
            avail['timeSlots'] ?? [],
          ); // timeSlots can be null or empty
          if (date != null) {
            // Only add if date is not null
            map[date] = timeSlots;
          }
        }
      }

      setState(() {
        _availabilitiesMap = map;
      });
    } catch (e) {
      debugPrint('Dio error in _fetchworkerAvailabilities: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          setState(() {
            _error = 'Access denied. Please check your login status.';
          });
        } else if (e.response?.statusCode == 401) {
          setState(() {
            _error = 'Please log in to manage availability.';
          });
        } else {
          setState(() {
            _error =
                'Failed to fetch availability data: ${e.response?.data['message'] ?? e.message}';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch availability data.';
        });
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    final formattedDate = _normalizeDate(selectedDay);
    setState(() {
      _selectedDate = selectedDay;
      _slots = _availabilitiesMap[formattedDate] ?? [];
    });
  }

  Future<void> _addSlot() async {
    if (_selectedDate == null || _slotController.text.isEmpty) return;

    final newSlot = _slotController.text.trim();
    if (_slots.contains(newSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This time slot already exists.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final formattedDate = _normalizeDate(_selectedDate!);
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to add availability.';
          _loading = false;
        });
        return;
      }

      final newSlots = [..._slots, newSlot];

      // Using ApiEndpoints.baseUrl for adding
      await Dio().post(
        '${ApiEndpoints.baseUrl}calendar/availabilities',
        data: {
          'propertyId': widget.propertyId,
          'date': formattedDate,
          'timeSlots': newSlots,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _slotController.clear();
      await _fetchworkerAvailabilities(); // Refresh the data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time slot added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Dio error in _addSlot: $e');
      if (e is DioException) {
        setState(() {
          _error =
              'Failed to add time slot: ${e.response?.data['message'] ?? e.message}';
        });
      } else {
        setState(() {
          _error = 'Failed to add time slot.';
        });
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _removeSlot(String slot) async {
    if (_selectedDate == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final formattedDate = _normalizeDate(_selectedDate!);
      final newSlots = _slots.where((s) => s != slot).toList();
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to remove availability.';
          _loading = false;
        });
        return;
      }

      if (newSlots.isEmpty) {
        // If no slots left, delete the entire availability for the date
        await _deleteAvailability();
        return;
      }

      // Using ApiEndpoints.baseUrl for updating after removal
      await Dio().post(
        '${ApiEndpoints.baseUrl}calendar/availabilities',
        data: {
          'propertyId': widget.propertyId,
          'date': formattedDate,
          'timeSlots': newSlots,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await _fetchworkerAvailabilities(); // Refresh the data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time slot removed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Dio error in _removeSlot: $e');
      if (e is DioException) {
        setState(() {
          _error =
              'Failed to remove time slot: ${e.response?.data['message'] ?? e.message}';
        });
      } else {
        setState(() {
          _error = 'Failed to remove time slot.';
        });
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteAvailability() async {
    if (_selectedDate == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final formattedDate = _normalizeDate(_selectedDate!);
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to delete availability.';
          _loading = false;
        });
        return;
      }

      // The backend should ideally have a DELETE endpoint for this.
      // If your backend POSTs with empty array to delete, keep this:
      // await Dio().post('${ApiEndpoints.baseUrl}calendar/availabilities',
      //   data: {
      //     'propertyId': widget.propertyId,
      //     'date': formattedDate,
      //     'timeSlots': [], // Sending empty array to signal deletion
      //   },
      //   options: Options(headers: {'Authorization': 'Bearer $token'}),
      // );
      // OR, if you implement a DELETE endpoint on your backend (recommended):

      await Dio().delete(
        '${ApiEndpoints.baseUrl}calendar/availabilities/${widget.propertyId}/$formattedDate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await _fetchworkerAvailabilities(); // Refresh the data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Availability deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Dio error in _deleteAvailability: $e');
      if (e is DioException) {
        setState(() {
          _error =
              'Failed to delete availability: ${e.response?.data['message'] ?? e.message}';
        });
      } else {
        setState(() {
          _error = 'Failed to delete availability.';
        });
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Manage Availability',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _selectedDate ?? DateTime.now(),
                selectedDayPredicate:
                    (day) =>
                        _selectedDate != null && isSameDay(day, _selectedDate),
                onDaySelected: _onDateSelected,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF003366),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final formatted = _normalizeDate(date);
                    if (_availabilitiesMap[formatted] != null &&
                        _availabilitiesMap[formatted]!.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),

            if (_selectedDate != null && !_loading)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Availability for: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (_slots.isEmpty)
                    const Text(
                      'No time slots set for this date.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    // Wrap potentially long list of slots in a SizedBox with ListView.builder
                    SizedBox(
                      // Estimate height based on number of slots; adjust 50.0 if needed
                      height:
                          _slots.length * 50.0 > 200
                              ? 200
                              : _slots.length * 50.0,
                      child: ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevent inner scrolling if outer scroll exists
                        itemCount: _slots.length,
                        itemBuilder: (context, index) {
                          final slot = _slots[index];
                          return ListTile(
                            title: Text(slot),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSlot(slot),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _slotController,
                          decoration: const InputDecoration(
                            hintText: 'Add time slot (e.g. 10:00 AM)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addSlot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),

                  if (_slots.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _deleteAvailability,
                        child: const Text('Delete All Slots for This Date'),
                      ),
                    ),
                ],
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
