import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';

// Import your ApiEndpoints file
import '../../../../app/constant/api_endpoints.dart';

class WorkerManageAvailability extends StatefulWidget {
  final String workerId;
  const WorkerManageAvailability({super.key, required this.workerId});

  @override
  State<WorkerManageAvailability> createState() =>
      _WorkerManageAvailabilityState();
}

class _WorkerManageAvailabilityState extends State<WorkerManageAvailability> {
  DateTime? _selectedDate;
  final TextEditingController _slotController = TextEditingController();
  List<String> _slots = [];
  bool _loading = false;
  String? _error;
  Map<String, Map<String, dynamic>> _availabilitiesMap = {};
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
    _fetchWorkerAvailabilities();
  }

  Future<void> _fetchWorkerAvailabilities() async {
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
        ApiEndpoints.getWorkerAvailabilities,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final availabilities = response.data['availabilities'] as List? ?? [];
      final map = <String, Map<String, dynamic>>{};

      for (var avail in availabilities) {
        final listingData = avail['workerListing'] as Map<String, dynamic>?;
        
        if (listingData != null && listingData['_id'] == widget.workerId) {
          final date = avail['date'] as String?;
          final timeSlots = List<String>.from(avail['timeSlots'] ?? []);
          final id = avail['_id'] as String?;
          
          if (date != null && id != null) {
            map[date] = {
              'id': id,
              'slots': timeSlots,
            };
          }
        }
      }

      setState(() {
        _availabilitiesMap = map;
        // Also update current selection slots if a date is already selected
        if (_selectedDate != null) {
          final formattedDate = _normalizeDate(_selectedDate!);
          _slots = _availabilitiesMap[formattedDate]?['slots'] ?? [];
        }
      });
    } catch (e) {
      debugPrint('Dio error in _fetchworkerAvailabilities: $e');
      if (e is DioException) {
        setState(() {
           _error = 'Failed to fetch availability: ${e.response?.data['message'] ?? e.message}';
        });
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
      _slots = _availabilitiesMap[formattedDate]?['slots'] ?? [];
    });
  }

  // ... (rest of the methods before _deleteAvailability)

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
          'workerListingId': widget.workerId,
          'date': formattedDate,
          'timeSlots': newSlots,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _slotController.clear();
      await _fetchWorkerAvailabilities(); // Refresh the data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Dio error in _addSlot: $e');
      String errorMessage = 'Failed to add time slot.';
      
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        } else if (e.message != null) {
          errorMessage = 'Failed to add time slot: ${e.message}';
        }
      }
      
      setState(() {
        _error = errorMessage;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
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
      final availabilityData = _availabilitiesMap[formattedDate];
      if (availabilityData == null) return;

      final availabilityId = availabilityData['id'];
      final originalSlots = List<String>.from(availabilityData['slots']);
      final newSlots = originalSlots.where((s) => s != slot).toList();
      
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

      // Update the slots for this availability ID
      await Dio().put(
        '${ApiEndpoints.baseUrl}calendar/availabilities/$availabilityId',
        data: {
          'timeSlots': newSlots,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await _fetchWorkerAvailabilities(); // Refresh the data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Dio error in _removeSlot: $e');
      String errorMessage = 'Failed to remove time slot.';
      
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        } else if (e.message != null) {
          errorMessage = 'Failed to remove time slot: ${e.message}';
        }
      }
      
      setState(() {
        _error = errorMessage;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
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
      final availabilityData = _availabilitiesMap[formattedDate];
      if (availabilityData == null) return;

      final availabilityId = availabilityData['id'];
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to delete availability.';
          _loading = false;
        });
        return;
      }

      // Use the correct DELETE endpoint with the record ID
      await Dio().delete(
        '${ApiEndpoints.baseUrl}calendar/availabilities/$availabilityId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await _fetchWorkerAvailabilities(); // Refresh the data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
        child: SingleChildScrollView(
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
                      final data = _availabilitiesMap[formatted];
                      if (data != null && (data['slots'] as List).isNotEmpty) {
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 180, // Giving it a fixed reasonable width to avoid stretching too much in Wrap
                          child: TextField(
                            controller: _slotController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 10:00 AM',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _addSlot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
      ),
    );
  }
}
