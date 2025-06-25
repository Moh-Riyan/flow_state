import 'package:flow_state/models/lapangan.dart'; // Import model Lapangan
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_state/pages/booking/info_pemesanan.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectSchedule extends StatefulWidget {
  // --- PERUBAHAN DI SINI ---
  final Lapangan lapangan; // Tambahkan properti untuk menerima data lapangan
  const SelectSchedule({super.key, required this.lapangan}); // Perbarui constructor

  @override
  _SelectScheduleState createState() => _SelectScheduleState();
}

class _SelectScheduleState extends State<SelectSchedule> {
  late DateTime _selectedDate;
  List<TimeOfDay> _selectedTimes = [];
  Set<DateTime> _bookedTimes = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  bool _isTimeBooked(TimeOfDay time) {
    DateTime currentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    return _bookedTimes.contains(currentDateTime);
  }

  bool _isTimeRestricted(TimeOfDay time) {
    return time.hour >= 0 && time.hour <= 5;
  }

  String formatTimeToIndonesiaWIB(TimeOfDay time) {
    final DateTime dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    final String formattedTime = DateFormat('HH:mm').format(dateTime);
    return '$formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pilih Jadwal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 1).add(Duration(days: 365)),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                },
                locale: 'id_ID',
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 208, 138),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  disabledTextStyle: TextStyle(color: Colors.grey.shade700),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white),
                  formatButtonTextStyle: TextStyle(color: Colors.black),
                  formatButtonVisible: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  titleCentered: true,
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Waktu:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),

              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,  // Menyesuaikan rasio aspek untuk membuat waktu lebih terpusat
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final time = TimeOfDay(hour: index, minute: 0);
                  return InkWell(
                    onTap: _isTimeBooked(time) || _isTimeRestricted(time)
                        ? null
                        : () {
                            setState(() {
                              // Cek apakah waktu sudah dipilih
                              if (_selectedTimes.length < 2 || _selectedTimes.contains(time)) {
                                if (_selectedTimes.contains(time)) {
                                  // Hapus waktu jika sudah dipilih
                                  _selectedTimes.remove(time);
                                  _bookedTimes.remove(
                                    DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      time.hour,
                                      time.minute,
                                    ),
                                  );
                                } else {
                                  // Pilih waktu jika belum dipilih
                                  _selectedTimes.add(time);
                                  _bookedTimes.add(
                                    DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      time.hour,
                                      time.minute,
                                    ),
                                  );
                                }
                              } else {
                                // Jika sudah ada dua waktu, beri peringatan
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Batas Pemilihan Waktu'),
                                    content: Text('Anda hanya dapat memilih dua waktu pemesanan.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              _selectedTimes.sort((a, b) => a.compareTo(b));
                            });
                          },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _selectedTimes.contains(time)
                            ? Colors.orange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${formatTimeToIndonesiaWIB(time)}',
                            style: TextStyle(
                              color: _isTimeRestricted(time) ? Colors.grey : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedTimes.isEmpty || _selectedTimes.length < 2) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Pilih Waktu yang Valid'),
                        content: Text('Pastikan Anda memilih dua waktu pemesanan!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Tutup dialog
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // --- PERUBAHAN DI SINI ---
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingInfoPage(
                          lapangan: widget.lapangan, // Kirimkan data lapangan
                          selectedDate: _selectedDate,
                          selectedTimes: _selectedTimes,
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _selectedDate = DateTime.now();
                        _selectedTimes.clear();
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 5),
                ),
                child: Text(
                  'Pilih',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension untuk perbandingan TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}