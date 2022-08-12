import 'package:book_calendor_test/src/core/booking_calendar.dart';
import 'package:book_calendor_test/src/core/booking_calendar_bloc.dart';
import 'package:book_calendor_test/src/util/booking_util.dart';
import 'package:flutter/material.dart';

import 'src/model/booking_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const BookingCalendarDemoApp());
}

class BookingCalendarDemoApp extends StatefulWidget {
  const BookingCalendarDemoApp({Key? key}) : super(key: key);

  @override
  State<BookingCalendarDemoApp> createState() => _BookingCalendarDemoAppState();
}

class _BookingCalendarDemoAppState extends State<BookingCalendarDemoApp> {
  final now = DateTime.now();
  final bookingBloc = BookingBloc();


  late BookingService mockBookingService;

  @override
  void initState() {
    super.initState();
    // DateTime.now().startOfDay;
    // // DateTime.now().endOfDay

    // mockBookingService = BookingService(
    //     companyId: 1,
    //     //07.01 추가 해당하는 날짜의 예약된 시간의 start 리스트 List<DateTime>
    //     bookedStartList: [
    //       DateTime(now.year, now.month, now.day, 2, 0),
    //       DateTime(now.year, now.month, now.day, 4, 0),
    //       DateTime(now.year, now.month, now.day, 7, 30),
    //       DateTime(now.year, now.month, now.day, 5, 0),
    //     ],
    //     //07.01 추가 해당하는 날짜의 예약된 시간의 end 리스트 List<DateTime>
    //     bookedEndList: [
    //       DateTime(now.year, now.month, now.day, 3, 30),
    //       DateTime(now.year, now.month, now.day, 4, 30),
    //       DateTime(now.year, now.month, now.day, 8, 0),
    //       DateTime(now.year, now.month, now.day, 5, 30),
    //     ],
    //     bookingEnd: DateTime(now.year, now.month, now.day, 9, 0),
    //     bookingStart: DateTime(now.year, now.month, now.day, 2, 0));
  }


  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    print("in demo getBookingStreamMock 시작");
    print("in demo start : $start");
    print("in demo end : $end");
    print("in demo getBookingStreamMock 끝");

    return bookingBloc.bookingResult;
  }

  Future<dynamic> uploadBookingMock(
      {required BookingService newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));
    print('${newBooking.toJson()} has been uploaded');
  }

  List<DateTimeRange> converted = [];

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    print("in demo convertStreamResultMock 시작");
    print("in demo convertStreamResultMock streamResult : ${streamResult}");

    //07.07 추가 기존의 converted 를 clear 하여 이전 stream 결과 값을 지우고 새 결과값으로 채운다.
    converted.clear();

    ///here you can parse the streamresult and convert to [List<DateTimeRange>]
    // DateTime first = now;
    // DateTime second = now.add(const Duration(minutes: 55));
    // DateTime third = now.subtract(const Duration(minutes: 240));
    // DateTime fourth = now.subtract(const Duration(minutes: 500));

    //07.07 추가 bookingStream의 결과 값을 다시 mockBookingService에 할당한다.
    mockBookingService = streamResult;
    print("convertStreamResultMock bookedStartList ${mockBookingService.bookedStartList}");



    ///converted 리스트 요소에 DateTimeRange를 start = bookedStartList[i]로 할당하였고
    ///end = bookedEndList[i]로 할당하였다.
    ///(정상 작동) - 유지보수 필요 (동적 할당) widget에 동작 추가하는 방향으로
    for (int i = 0; i < mockBookingService.bookedStartList!.length; i++) {
      converted.add(DateTimeRange(
          start: mockBookingService.bookedStartList!.elementAt(i),
          end: mockBookingService.bookedEndList!.elementAt(i)));
    }
    // 값 확인 로그
    // print('in main demo convertStreamResultMock first : ${first}');
    // print('in main demo convertStreamResultMock second : ${second}');
    // print('in main demo convertStreamResultMock third : ${third}');
    // print('in main demo convertStreamResultMock fourth : ${fourth}');

    //원본 code
    // converted.add(
    //     DateTimeRange(start: first, end: now.add(const Duration(minutes: 30))));
    // converted.add(DateTimeRange(
    //     start: second, end: second.add(const Duration(minutes: 23))));
    // converted.add(DateTimeRange(
    //     start: third, end: third.add(const Duration(minutes: 15))));
    // converted.add(DateTimeRange(
    //     start: fourth, end: fourth.add(const Duration(minutes: 50))));
    print('in main demo convertStreamResultMock converted : ${converted}');
    print("in demo convertStreamResultMock 종료");
    return converted;
  }

  List<DateTimeRange> pauseSlots = [
    DateTimeRange(
        start: DateTime.now().add(const Duration(minutes: 5)),
        end: DateTime.now().add(const Duration(minutes: 60)))
  ];




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Booking Calendar Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('예약 하기'),
          ),
          body: StreamBuilder(
            stream: bookingBloc.bookingResult,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                mockBookingService = snapshot.data!;
                return Center(
                  child: BookingCalendar(
                    bookingService: mockBookingService,
                    convertStreamResultToDateTimeRanges: convertStreamResultMock,
                    getBookingStream: getBookingStreamMock,
                    uploadBooking: uploadBookingMock,
                    bookingGridCrossAxisCount: 4,

                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
          ),
        ));
  }
}
