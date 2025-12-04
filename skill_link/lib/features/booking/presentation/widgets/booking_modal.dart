import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';

// Import your ApiEndpoints file
import '../../../../app/constant/api_endpoints.dart';

class BookingModal extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final VoidCallback? onBookingSuccess;

  const BookingModal({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    this.onBookingSuccess,
  });

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  bool _booking = false;
  String? _error;
  final Map<String, List<String>> _availableSlotsMap = {};
  final TokenSharedPrefs _tokenSharedPrefs = TokenSharedPrefs(
    sharedPreferences: serviceLocator(),
  );

  Future<String?> _getToken() async {
    final tokenEither = await _tokenSharedPrefs.getToken();
    return tokenEither.fold((l) => null, (r) => r);
  }

  String _normalizeDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(d);
  }

  Future<void> _fetchSlots(DateTime date) async {
    setState(() {
      _loadingSlots = true;
      _error = null;
    });
    try {
      final formattedDate = _normalizeDate(date);
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to book a visit.';
          _loadingSlots = false;
        });
        return;
      }

      // Using ApiEndpoints.baseUrl here
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}calendar/properties/${widget.propertyId}/available-slots',
        queryParameters: {'date': formattedDate},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      setState(() {
        _availableSlots = List<String>.from(
          response.data['availableSlots'] ?? [],
        );
        _availableSlotsMap[formattedDate] = _availableSlots;
        _selectedSlot = null;
      });
    } catch (e) {
      debugPrint('Dio error in _fetchSlots: $e');
      if (e is DioException) {
        // Use DioException for type checking
        if (e.response?.statusCode == 403) {
          setState(() {
            _error = 'Access denied. Please check your login status.';
          });
        } else if (e.response?.statusCode == 401) {
          setState(() {
            _error = 'Please log in to book a visit.';
          });
        } else {
          setState(() {
            _error = 'Failed to fetch available slots: ${e.message}';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch available slots.';
        });
      }
    } finally {
      setState(() {
        _loadingSlots = false;
      });
    }
  }

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    final formattedDate = _normalizeDate(selectedDay);
    setState(() {
      _selectedDate = selectedDay;
      _selectedSlot = null;
    });

    // Check if we already have slots for this date
    if (_availableSlotsMap.containsKey(formattedDate)) {
      setState(() {
        _availableSlots = _availableSlotsMap[formattedDate] ?? [];
      });
    } else {
      _fetchSlots(selectedDay);
    }
  }

  Future<void> _bookVisit() async {
    if (_selectedDate == null || _selectedSlot == null) return;

    setState(() {
      _booking = true;
      _error = null;
    });
    try {
      final formattedDate = _normalizeDate(_selectedDate!);
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to book a visit.';
          _booking = false;
        });
        return;
      }

      // Using ApiEndpoints.baseUrl here
      await Dio().post(
        '${ApiEndpoints.baseUrl}calendar/book-visit',
        data: {
          'propertyId': widget.propertyId,
          'date': formattedDate,
          'timeSlot': _selectedSlot,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (widget.onBookingSuccess != null) widget.onBookingSuccess!();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Visit booked successfully! Awaiting worker confirmation.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Dio error in _bookVisit: $e');
      if (e is DioException) {
        // Use DioException for type checking
        if (e.response?.statusCode == 409) {
          setState(() {
            _error = 'This time slot is already booked. Please choose another.';
          });
        } else if (e.response?.statusCode == 400) {
          setState(() {
            _error = 'Invalid booking request. Please try again.';
          });
        } else {
          setState(() {
            _error =
                'Failed to book visit: ${e.response?.data['message'] ?? e.message}';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to book visit. Please try again.';
        });
      }
    } finally {
      setState(() {
        _booking = false;
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
          // Added SingleChildScrollView to prevent potential overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Book a Visit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              Text(
                widget.propertyTitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

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
                    if (_availableSlotsMap[formatted] != null &&
                        _availableSlotsMap[formatted]!.isNotEmpty) {
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

              if (_loadingSlots)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (_selectedDate != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Available Slots for: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (_availableSlots.isEmpty)
                      const Text(
                        'No available slots for this date.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _availableSlots
                                .map(
                                  (slot) => ChoiceChip(
                                    label: Text(slot),
                                    selected: _selectedSlot == slot,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedSlot = selected ? slot : null;
                                      });
                                    },
                                    selectedColor: const Color(0xFF003366),
                                    labelStyle: TextStyle(
                                      color:
                                          _selectedSlot == slot
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _booking || _selectedDate == null || _selectedSlot == null
                          ? null
                          : _bookVisit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _booking
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Booking...'),
                            ],
                          )
                          : const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
