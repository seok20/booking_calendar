import 'package:book_calendor_test/src/components/booking_dialog.dart';
import 'package:book_calendor_test/src/components/booking_explanation.dart';
import 'package:book_calendor_test/src/components/booking_slot.dart';
import 'package:book_calendor_test/src/components/common_button.dart';
import 'package:book_calendor_test/src/components/common_card.dart';
import 'package:book_calendor_test/src/core/booking_calendar_bloc.dart';
import 'package:book_calendor_test/src/core/booking_controller.dart';
import 'package:book_calendor_test/src/model/booking_service.dart';
import 'package:book_calendor_test/src/next_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:book_calendor_test/src/util/booking_util.dart';
import 'package:intl/date_symbol_data_local.dart';

class BookingCalendarMain extends StatefulWidget {
  const BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.uploadBooking,
    this.bookingExplanation,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonText,
    this.bookingButtonColor,
    this.bookedSlotColor,
    this.selectedSlotColor,
    this.availableSlotColor,
    this.bookedSlotText,
    this.selectedSlotText,
    this.availableSlotText,
    this.gridScrollPhysics,
    this.loadingWidget,
    this.errorWidget,
    this.uploadingWidget,
    this.pauseSlotColor,
    this.pauseSlotText,
    this.hideBreakTime = false,
  }) : super(key: key);

  final Stream<dynamic>? Function(
      {required DateTime start, required DateTime end}) getBookingStream;

  final Future<dynamic> Function({required BookingService newBooking})
      uploadBooking;

  final List<DateTimeRange> Function({required dynamic streamResult})
      convertStreamResultToDateTimeRanges;

  ///Customizable
  final Widget? bookingExplanation;
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final String? bookingButtonText;
  final Color? bookingButtonColor;
  final Color? bookedSlotColor;
  final Color? selectedSlotColor;
  final Color? availableSlotColor;
  final Color? pauseSlotColor;

  final String? bookedSlotText;
  final String? selectedSlotText;
  final String? availableSlotText;
  final String? pauseSlotText;

  final ScrollPhysics? gridScrollPhysics;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? uploadingWidget;

  final bool? hideBreakTime;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain> {
  late BookingController controller;
  final now = DateTime.now();
  final bookingBloc = BookingBloc();

  @override
  void initState() {
    super.initState();
    controller = context.read<BookingController>();
    startOfDay = now.startOfDay;
    endOfDay = now.endOfDay;
    _focusedDay = now;
    _selectedDay = now;
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    print("in main. selectNewDateRange 시작");
    // startOfDay = controller.serviceOpening!;
    print('in main. selectNewDateRange startOfDay before : ${startOfDay}');
    startOfDay = _selectedDay.startOfDay;
    print('in main. selectNewDateRange startOfDay after : ${startOfDay}');

    endOfDay = _selectedDay.add(const Duration(days: 1)).endOfDay;

    /// 07.01 추가 기존 controller.base = startOfDay 에서
    /// controller.serviceOpening!.hour 를 추가로 더함
    /// (정상 작동)
    print(
        "in main. selectNewDateRange before controller.base : ${controller.base}");

    controller.base = startOfDay;
    controller.base =
        controller.base.add(Duration(hours: controller.serviceOpening!.hour));
    print(
        "in main. selectNewDateRange after controller.base : ${controller.base}");
    controller.resetSelectedSlot();

    print("in main. selectNewDateRange 종료");
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();

    return Consumer<BookingController>(
      builder: (_, controller, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: (controller.isUploading)
            ? widget.uploadingWidget ?? const BookingDialog()
            : Column(
                children: [
                  CommonCard(
                    child: TableCalendar(
                      locale: 'ko-KR',
                      // 언어 설정
                      firstDay: DateTime.now(),
                      // 현재 날짜 설정
                      lastDay: DateTime.now().add(const Duration(days: 1000)),
                      // 마지막 날짜 설정
                      focusedDay: _focusedDay,
                      // 선택된 날짜 초기화 (오늘)
                      calendarFormat: _calendarFormat,
                      // 캘린더 형식 초기화 (2주)
                      availableCalendarFormats: const {
                        // 캘린더 헤더 형식 초기화
                        CalendarFormat.month: '1주',
                        CalendarFormat.twoWeeks: '한달',
                        CalendarFormat.week: '2주',
                      },

                      ///캘린더 스타일 설정
                      calendarStyle:
                          const CalendarStyle(isTodayHighlighted: true),

                      /// 날짜 선택 후 선택한 날짜와 selectedDay와 비교하여 같은지 다른지 판단 후 다르면 selectedDay 설정
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          //07.07 날짜에 맞는 api 호출
                          bookingBloc.touch();
                          selectNewDateRange();
                        }
                      },

                      /// 달력 형식 변경 이벤트 처리
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },

                      /// 페이지 변경 이벤트 처리
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                  const SizedBox(height: 8), // 마진
                  widget.bookingExplanation ?? // bookingExplanation 없으면 아래 걸로
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        direction: Axis.horizontal,
                        children: [
                          BookingExplanation(
                              color: widget.availableSlotColor ??
                                  Colors.greenAccent,
                              text: widget.availableSlotText ?? "예약 가능"),
                          BookingExplanation(
                              color: widget.selectedSlotColor ??
                                  Colors.orangeAccent,
                              text: widget.selectedSlotText ?? "선택됨"),
                          BookingExplanation(
                              color: widget.bookedSlotColor ?? Colors.redAccent,
                              text: widget.bookedSlotText ?? "예약 완료"),
                          if (widget.hideBreakTime != null &&
                              widget.hideBreakTime == false)
                            BookingExplanation(
                                color: widget.pauseSlotColor ?? Colors.grey,
                                text: widget.pauseSlotText ?? "Break"),
                        ],
                      ),
                  const SizedBox(height: 8),

                  ///Stream Builder
                  StreamBuilder<dynamic>(
                    //07.07 수정 bookingBloc.bookingResult로 stream을 수정하였음
                    stream: bookingBloc.bookingResult,
                    // stream: widget.getBookingStream(
                    //     start: startOfDay.add(Duration(hours: controller.serviceOpening!.hour)), end: startOfDay.add(Duration(hours: controller.serviceClosing!.hour))),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return widget.errorWidget ??
                            Center(
                              child: Text(snapshot.error.toString()),
                            );
                      }

                      if (!snapshot.hasData) {
                        return widget.loadingWidget ??
                            const Center(child: CircularProgressIndicator());
                      }

                      ///this snapshot should be converted to List<DateTimeRange>
                      /// 여기서 캘린더 하단 시간 선택 slot이 생성
                      final data = snapshot.requireData;
                      print("booking_calendar_main in Stream data: $data");

                      print('in main snapshot : ${snapshot.data.isClosed}');
                      //07.08 추가 isClosed의 값에 따라 BookingSlot의 생성을 관리한다.
                      if (!snapshot.data.isClosed) {
                        controller.generateBookedSlots(
                            widget.convertStreamResultToDateTimeRanges(
                                streamResult: data));
                        return Expanded(
                          child: GridView.builder(
                            // 스크롤 가능한 위젯의 물리적 특성 결정
                            physics: widget.gridScrollPhysics ??
                                const BouncingScrollPhysics(),
                            itemCount: controller.allBookingSlots.length,
                            itemBuilder: (context, index) {
                              final slot =
                                  controller.allBookingSlots.elementAt(index);

                              return BookingSlot(
                                hideBreakSlot: widget.hideBreakTime,
                                pauseSlotColor: widget.pauseSlotColor,
                                availableSlotColor: widget.availableSlotColor,
                                bookedSlotColor: widget.bookedSlotColor,
                                selectedSlotColor: widget.selectedSlotColor,
                                isPauseTime: controller.isSlotInPauseTime(slot),
                                isBooked: controller.isSlotBooked(index),
                                isSelected: index == controller.selectedSlot,
                                onTap: () => controller.selectSlot(index),
                                child: Center(
                                  child: Text(
                                    widget.formatDateTime?.call(slot) ??
                                        BookingUtil.formatDateTime(slot),
                                  ),
                                ),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  widget.bookingGridCrossAxisCount ?? 3,
                              childAspectRatio:
                                  widget.bookingGridChildAspectRatio ?? 1.5,
                            ),
                          ),
                        );
                      } else {
                        return const Center(child: Text('휴무일'));
                      }
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  CommonButton(
                    text: widget.bookingButtonText ?? '예약하기',
                    onTap: () {
                      controller.toggleUploading();
                      // await widget.uploadBooking(
                      //     newBooking:
                      //         controller.generateNewBookingForUploading());
                      print('${controller.generateNewBookingForUploading().bookingStart}');
                      var tempDate = controller.generateNewBookingForUploading().bookingStart;

                      controller.toggleUploading();
                      controller.resetSelectedSlot();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NextStatePage(
                                data: tempDate,
                              )));
                      //다음 페이지 이동

                    },
                    isDisabled: controller.selectedSlot == -1,
                    buttonActiveColor: widget.bookingButtonColor,
                  ),
                ],
              ),
      ),
    );
  }
}
