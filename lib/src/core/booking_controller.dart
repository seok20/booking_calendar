import 'package:book_calendor_test/src/model/booking_service.dart';
import 'package:book_calendor_test/src/util/booking_util.dart';
import 'package:flutter/material.dart';

class BookingController extends ChangeNotifier {
  //07.07 추가
  final now = DateTime.now();
  
  BookingService bookingService;
  BookingController({required this.bookingService, this.pauseSlots}) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    pauseSlots = pauseSlots;
    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    // print('생성자 serviceOpening');
    // print(serviceOpening);

    base = serviceOpening!;
    print("생성자 호출됨 \n base");
    print(base);
    print(serviceOpening);
    _generateBookingSlots();
  }

  late DateTime base;

  DateTime? serviceOpening;
  DateTime? serviceClosing;

  List<DateTime> _allBookingSlots = [];
  List<DateTime> get allBookingSlots => _allBookingSlots;

  List<DateTimeRange> testBookedSlot = [DateTimeRange(start: DateTime.now().add(const Duration(hours: 9,minutes: 20)), end: DateTime.now().add(const Duration(hours: 9,minutes: 30)))];

  List<DateTimeRange> bookedSlots = [];
  List<DateTimeRange>? pauseSlots = [];

  int _selectedSlot = (-1);
  bool _isUploading = false;

  int get selectedSlot => _selectedSlot;
  bool get isUploading => _isUploading;

  void _generateBookingSlots() {
    print("in controller _generateBookingSlots 시작");
    allBookingSlots.clear();
    print("in controller _generateBookingSlots base : ${base}");
    print("in controller _generateBookingSlots serviceOpening : ${serviceOpening}");

    /// 기존 DateTime 변수 base -> serviceOpening!으로 변경 정상 작동
    _allBookingSlots = List.generate(
        _maxServiceFitInADay(),
        ///base는 BookingSlots의 시작 지점으로 booking_calendar_main안에 selectNewDateRange()에서 startOfDay로 재할당한다.
        (index) => base
            .add(Duration(minutes: bookingService.serviceDuration) * index));

    print("in controller _generateBookingSlots 끝");
  }

  int _maxServiceFitInADay() {

    print("in controller _maxServiceFitInADay 시작");
    ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
    int openingHours = 24;
    //
    // print("서비스 오프닝 시간");
    // print(serviceOpening);
    // print("서비스 클로즈 시간");
    // print(serviceClosing);

    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!)
          .duration
          .inHours;
    }

    // print("오프닝 hour");
    // print(openingHours);
    // print("bookingService.serviceDuration");
    // print(bookingService.serviceDuration);
    // print((openingHours * 60) / bookingService.serviceDuration);

    print("in controller _maxServiceFitInADay 끝");
    ///round down if not the whole service would fit in the last hours
    return ((openingHours * 60) / bookingService.serviceDuration).floor();
  }

  bool isSlotBooked(int index) {

    DateTime checkSlot = allBookingSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
          checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }

    return result;
  }

  void selectSlot(int idx) {
    _selectedSlot = idx;
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedSlot = -1;
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<DateTimeRange> data) async {
    print("in controller generateBookedSlots 시작");
    print("in controller generateBookedSlots data : $data");

    bookedSlots.clear();
    _generateBookingSlots();

    // print('data');
    // print(data);

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      bookedSlots.add(item);
    }
    print("in controller generateBookedSlots 끝");

  }

  DateTime getSelectDateTime(){
    final bookingDate = allBookingSlots.elementAt(selectedSlot);
    return bookingDate;
  }
  BookingService generateNewBookingForUploading() {
    final bookingDate = allBookingSlots.elementAt(selectedSlot);
    bookingService
      ..bookingStart = (bookingDate)
      ..bookingEnd =
          (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
    return bookingService;
  }

  bool isSlotInPauseTime(DateTime slot) {
    bool result = false;
    if (pauseSlots == null) {
      return result;
    }
    for (var pauseSlot in pauseSlots!) {
      if (BookingUtil.isOverLapping(pauseSlot.start, pauseSlot.end, slot,
          slot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }
}
