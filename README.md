## booking_calendar

달력 기반의 예약 서비스 기능 라이브러리
기존 라이브러리를 수정

출처:[https://github.com/radikris/booking_calendar]

## 목차
1. [calendar customzing]
2. [달력 날짜 클릭 시 bookSlots 변경 (selectNewDateRange 재설정)]
3. [BookingService 생성자 재설정 (수정 요망)]
4. [업체에 해당하는 예약 현황에 따라 bookSlots 변경(convertStreamResultMock 재설정)]
5. [http 통신을 통한 companyBooking Bloc 구현]
6. [http 통신 Test를 위한 Postman Test Json file 구축]
7. [#103으로 선택한 날짜의 시간을 전달]
8. [휴무일 처리]

### calendar customzing

해당 라이브러리는 table_calendar와 booking_calendar를 사용한 예약 서비스 달력이다.

두 외부 라이브러리를 사용한 것임으로 두 라이브러리의 ui 및 기능 수정이 따로 이루어진다.

해당 문서에서 다루는 내용은 2가지 방법에 대해 고찰한 결과이다.

### 기본 UI

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a3f43db1-97bc-42dc-920c-e89615ba99db/Untitled.png)

## Table Calendar Option

```dart
TableCalendar(	
	locale: 'ko-KR',                                       // 언어 설정
  firstDay: DateTime.now(),                              // 현재 날짜 설정
  lastDay: DateTime.now().add(const Duration(days: 1000)),// 마지막 날짜 설정
  focusedDay: _focusedDay,                               // 선택된 날짜 초기화 (오늘)
  calendarFormat: _calendarFormat,                       // 캘린더 형식 초기화 (2주)
  availableCalendarFormats: const {                      // 캘린더 헤더 형식 초기화
    CalendarFormat.month: '1주',
    CalendarFormat.twoWeeks: '한달',
    CalendarFormat.week: '2주',
  },
///캘린더 스타일 설정
calendarStyle:
      const CalendarStyle(isTodayHighlighted: true),
///날짜 선택 후 선택한 날짜와 selectedDay와 비교하여
///같은지 다른지 판단 후 다르면 selectedDay설정
selectedDayPredicate: (day) {
    return isSameDay(_selectedDay, day);
  },
  onDaySelected: (selectedDay, focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      selectNewDateRange();
    }
  },
///달력 형식 변경 이벤트 처리
onFormatChanged: (format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  },
///페이지 변경 이벤트 처리
onPageChanged: (focusedDay) {
    _focusedDay = focusedDay;
  },
),
```

⇒ TableCalendar에 대한 ui, event 처리에 대한 내용이다. 이외 method 및 componets는 table_calendar.dart 파일에서 확인할 수 있다.

## Booking Calendar Option

```dart
BookingCalendarMain(
        key: key,
        getBookingStream: getBookingStream,                       //사용자가 선택한 시간 slot을 realtime으로 확인하여 상태 변환하는 function
        uploadBooking: uploadBooking,                             //사용자가 선택한 날짜와 시간을 서버에 upload하는 function
        bookingButtonColor: bookingButtonColor,                   //예약하기 버튼 색상
        bookingButtonText: bookingButtonText,                     //예약하기 버튼 Text
        bookingExplanation: bookingExplanation,                   //Booking Slot 상태 설명
        bookingGridChildAspectRatio: bookingGridChildAspectRatio, //Booking Slot height
        bookingGridCrossAxisCount: bookingGridCrossAxisCount,     //Booking Slot 열 개수
        formatDateTime: formatDateTime,                           //Booking Slot DateTime 형식 (시간 형식)
        convertStreamResultToDateTimeRanges:
            convertStreamResultToDateTimeRanges,                  //Stream result 값을 DataTimeRange로 변경
        availableSlotColor: availableSlotColor,                   //예약 가능 Slot 색상
        availableSlotText: availableSlotText,                     //예약 가능 Slot Text
        bookedSlotColor: bookedSlotColor,                         //예약 불가 Slot 색상
        bookedSlotText: bookedSlotText,                           //예약 불가 Slot Text
        selectedSlotColor: selectedSlotColor,                     //선택된 Slot 색상
        selectedSlotText: selectedSlotText,                       //선택된 Slot Text
        gridScrollPhysics: gridScrollPhysics,                     //Booking Slot 영역 gridScroll 설정
        loadingWidget: loadingWidget,                             //LoadingWidget 커스텀
        errorWidget: errorWidget,                                 //ErrorWidget 커스텀
        uploadingWidget: uploadingWidget,                         //uploadingWidget 커스텀
        pauseSlotColor: pauseSlotColor,                           //휴게시간 Slot 색상
        pauseSlotText: pauseSlotText,                             //휴게시간 Slot Text
        hideBreakTime: hideBreakTime,                             //휴게시간 setting boolean 값
      ),
```

⇒ BookingCalendar에 대한 ui및 event 처리이다. 이외 method 및 componets들은 각 compent별 dart 파일에서 확인 가능하다.

## 변경사항

`bookingGridCrossAxisCount: 4` : BookingSlot 열 개수 3→ 4 수정

```dart
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
```

 → BookingExplanation 한글로 수정

```dart
availableCalendarFormats: const {                         // 캘린더 헤더 형식 초기화
  CalendarFormat.month: '1주',
  CalendarFormat.twoWeeks: '한달',
  CalendarFormat.week: '2주',

},
```

→ CalendarFormat 양식 한글로 수정 및 현재 달력 형식으로 수정

```dart
CommonButton(
  text: widget.bookingButtonText ?? '예약하기', ...
```

→ 하단 예약하기 버튼 Text 수정. BookingSlot과 Button은 CommonButton.dart, CommonCard.dart에서 추가 수정이 가능하다.

```dart
TableCalendar(
  locale: 'ko-KR',
```

→ 달력 시간, 언어를 ‘ko-KR’로 수정

### 달력 날짜 클릭 시 bookSlots 변경 (selectNewDateRange 재설정)

```dart
void selectNewDateRange() {
  // startOfDay = controller.serviceOpening!;
  print('in main. selectNewDateRange startOfDay before : ${startOfDay}');
  startOfDay = _selectedDay.startOfDay;
  print('in main. selectNewDateRange startOfDay after : ${startOfDay}');

  endOfDay = _selectedDay.add(const Duration(days: 1)).endOfDay;

/// 07.01추가 기존 controller.base = startOfDay에서
/// controller.serviceOpening!.hour를 추가로 더함
/// (정상 작동)
print("in main. selectNewDateRange before controller.base : ${controller.base}");
  controller.base = startOfDay;
  controller.base = controller.base.add(Duration(hours: controller.serviceOpening!.hour));
  print("in main. selectNewDateRange after controller.base : ${controller.base}");
  controller.resetSelectedSlot();
}
```

해당 로직은 사용자가 달력의 날짜를 클릭하였을 때 선택한 날짜에 따라 DateRange를 바꿔주는 로직이다.

controller.base가 Controller.dart 파일의 `void _generateBookingSlots()` 에서 `_allBookingSlots` 리스트 생성 시 최초 시작 지점으로 할당된다. 따라서 해당 controller.base를 bookingModel 클래스 객체인 bookingStart의 hour와 맞추어 주는 작업이 필요하다.

`controller.base = controller.base.add(Duration(hours: controller.serviceOpening!.hour));`

여기서 `controller.serviceOpening`은 Controller.dart에서 정의된 변수로 `BookingService .bookingStart` 의 값이 할당된다.

따라서 최초 업체 bookingStart 값을 생성자를 통해 객체 생성을 하면 업체 별 bookingSlot이 생성된다.

```dart
**(변경전)**
mockBookingService = BookingService(
    serviceName: 'Mock Service',
    serviceDuration: 30,
    //시간 텀
    //07.01 추가 해당하는 날짜의 예약된 시간의 start 리스트 List<DateTime>
    bookedStartList: [
      DateTime(now.year, now.month, now.day, 2, 0),
      DateTime(now.year, now.month, now.day, 4, 0),
      DateTime(now.year, now.month, now.day, 7, 30),
      DateTime(now.year, now.month, now.day, 5, 0),
    ],
    //07.01 추가 해당하는 날짜의 예약된 시간의 end 리스트 List<DateTime>
    bookedEndList: [
      DateTime(now.year, now.month, now.day, 3, 30),
      DateTime(now.year, now.month, now.day, 4, 30),
      DateTime(now.year, now.month, now.day, 8, 0),
      DateTime(now.year, now.month, now.day, 5, 30),
    ],
    bookingEnd: DateTime(now.year, now.month, now.day, 9, 0),      //업체 종료 시간
    **bookingStart: DateTime(now.year, now.month, now.day, 2, 0));   //업체 오픈 시간**
```

//해당 생성자에서 bookingStart 객체를 통해 업체 오픈 시간을 할당한다.

```dart
**(변경후)**
//in booking_calendar_demo.dart

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
```

기존 방식은 initState에서 BookingService 생성자를 통해 초기화 하였으나 이는 dynamic하게 할당이 불가능한 static한 방식.

따라서 StreamBuilder를 사용해 BehaviorSubject bookingResult를 구독하여 실시간으로 변경되는 BookingService를 관찰할 수 있도록 변경하였다.

기존 initState()는 삭제.

### BookingService 생성자 재설정 (수정 요망)

```dart
BookingService(
    serviceName: 'Mock Service',
    serviceDuration: 30,
    //시간 텀
    //07.01 추가 해당하는 날짜의 예약된 시간의 start 리스트 List<DateTime>
    bookedStartList: [
      DateTime(now.year, now.month, now.day, 2, 0),
      DateTime(now.year, now.month, now.day, 4, 0),
      DateTime(now.year, now.month, now.day, 7, 30),
      DateTime(now.year, now.month, now.day, 5, 0),
    ],
    //07.01 추가 해당하는 날짜의 예약된 시간의 end 리스트 List<DateTime>
    bookedEndList: [
      DateTime(now.year, now.month, now.day, 3, 30),
      DateTime(now.year, now.month, now.day, 4, 30),
      DateTime(now.year, now.month, now.day, 8, 0),
      DateTime(now.year, now.month, now.day, 5, 30),
    ],
    bookingEnd: DateTime(now.year, now.month, now.day, 9, 0),
    bookingStart: DateTime(now.year, now.month, now.day, 2, 0));
```

BookingService 클래스는 Model 클래스이다. class 내용은 다음과 같다.

```dart
class BookingService {
///
  /// The userId of the currently logged user
  /// who will start the new booking
final String? userId;

/// The userName of the currently logged user
  /// who will start the new booking
final String? userName;

/// The userEmail of the currently logged user
  /// who will start the new booking
final String? userEmail;

/// The userPhoneNumber of the currently logged user
  /// who will start the new booking
final String? userPhoneNumber;

/// The id of the currently selected Service
  /// for this service will the user start the new booking

final String? serviceId;

///The name of the currently selected Service
final String serviceName;

///The duration of the currently selected Service

final int serviceDuration;

///The price of the currently selected Service

final int? servicePrice;

///The selected booking slot's starting time
DateTime bookingStart;

///The selected booking slot's ending time
DateTime bookingEnd;

///07.01추가 BookedDateList[]추가함
///해당하는 업체의 예약된 시간 배열을 담기 위해 선언
List<DateTime>? bookedStartList;

List<DateTime>? bookedEndList;
```

기존과 달리 추가된 사항은 하기 객체가 추가되었다는 점이다.

```dart
List<DateTime>? bookedStartList;   //업체 별 예약 된 시간의 시작 시간을 담은 List

List<DateTime>? bookedEndList;     //업체 별 예약 된 시간의 끝 시간을 담은 List
```

### 업체에 해당하는 예약 현황에 따라 bookSlots 변경(convertStreamResultMock 재설정)

해당 파트에서는 업체의 예약 현황을 stream으로 받아와 동적으로 예약 시간을 처리하는 method이다. booking_calendar_demo(mainApp)에 정의되어 있다.

```dart
List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
///here you can parse the streamresult and convert to [List<DateTimeRange>]
//기존의 다른 날짜의 converted를 삭제한다. (초기화)
converted.clear()
  //DateTime second = now.add(const Duration(minutes: 55));
  //DateTime third = now.subtract(const Duration(minutes: 240));
  //DateTime fourth = now.subtract(const Duration(minutes: 500));

//steram result로 받은 결과 값을 기존 mockBookingService에 재할당한다.
mockBookingService = streamResult;

///converted리스트 요소에 DateTimeRange를 start = bookedStartList[i]로 할당하였고
///end = bookedEndList[i]로 할당하였다.
  ///(정상 작동) -유지보수 필요 (동적 할당) widget에 동작 추가하는 방향으로
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
  return converted;
}
```

변수 converted는 List<DateTimeRange> 자료형으로 업체의 예약된 시간의 시작 시간과 끝시간을 Range로 할당한 DateTimeRange 리스트이다.

업체의 예약된 시간의 시작 시간과 끝 시간은 각각 `strat: mockBookingService.bookedStartList end: mockBookingService.bookedEndList` 객체에 할당되어 있다.

해당 리스트를 반복문을 통해 converted에 할당시켜주고 반환한다.

- 해당 작업은 70% 완료되었고 추후 selectNewDateRange 시 해당 날짜의 예약 현황을 Request하는 작업이 이루어져야 한다. (07.07 해결)

```dart
//in booking_calendar_main.dart
...
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
```

해당 파트 (in booking_calendar_main.dart)에서 날짜 클릭 시 bookingBlock의 touch() 메소드를 호출하여 해당 날짜에 해당하는 예약 현황을 요청한다.

```dart
//in booking_calendar_main.dart

StreamBuilder<dynamic>(
  **//07.07 수정 bookingBloc.bookingResult로 stream을 수정하였음**
  **stream: bookingBloc.bookingResult,**
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
    ///여기서 캘린더 하단 시간 선택 slot이 생성
final data = snapshot.requireData;
    print("booking_calendar_main in Stream data: $data");

    controller.generateBookedSlots(
        widget.convertStreamResultToDateTimeRanges(
            streamResult: data));
```

해당 파트에서 Stream Builder의 stream source를 기존 getBookingSteram에서 bookingBloc의 BehaviorSubject bookingResult로 변경하여 호출로 인해 변경되는 BookingService를 구독하였다.

### http 통신을 통한 companyBooking Bloc 구현

```dart
//in bookingCalendar_bloc.dart

class BookingBloc{
  final _bookingSubject = BehaviorSubject<BookingService>();

  var count = 0;

  final url = Uri.parse("https://cbb5a17f-f6ca-4c30-bd18-b01a8674952c.mock.pstmn.io");
  final url2 = Uri.parse("https://cbb5a17f-f6ca-4c30-bd18-b01a8674952c.mock.pstmn.io/test1");

  Future<BookingService> fetchData() async{
    count++;
    print("$count 번 실행");
    var response = await http.get(url);

    BookingService result = BookingService.fromJson(json.decode(response.body));

    print("fetchData()내에서 ${result.bookedEndList}");
    return result;
  }
  Future<BookingService> fetchData2() async{
    count++;
    print("$count 번 실행");
    var response = await http.get(url2);

    BookingService result = BookingService.fromJson(json.decode(response.body));

    print("fetchData()내에서 ${result.bookedEndList}");
    return result;
  }

  BookingBloc(){
    fetch();
  }

  void fetch() async{
    var bookingResult = await fetchData();
    _bookingSubject.add(bookingResult);
  }
  void fetch2() async{
    var bookingResult = await fetchData2();
    _bookingSubject.add(bookingResult);
  }

  Stream<BookingService> get bookingResult => _bookingSubject.stream;

  void touch(){
    fetch2();
  }
}
```

해당 코드는 BookingCalendar의 Bloc 방식으로 state 관리를 하기 위한 코드이다.

위 로직은 구동 확인을 위한 sample Logic으로 추후 Retrofit과 DIO를 추가하여 수정 될 예정이다.

→ 기능 정상확인을 위해 작성됨

### http 통신 Test를 위한 Postman Test Json file 구축

```json
{
    "bookingStart" : "2022-07-08 09:00:00.00",
    "bookingEnd" : "2022-07-08 18:00:00.00",
    "serviceDuration" : 30,
    "companyId" : 1,
		"bookedStartList" : [
			"2022-07-08 09:00:00.00",
			"2022-07-08 10:00:00.00",
			"2022-07-08 12:30:00.00",
			"2022-07-08 17:00:00.00"
		],
		"bookedEndList" : [
      "2022-07-08 09:30:00.00",
			"2022-07-08 10:30:00.00",
			"2022-07-08 13:30:00.00",
			"2022-07-08 17:30:00.00"
		]
}
```

해당 Json file은 #102 Api Document에 정의되어 있는 양식을 바탕으로 구축하였다.

현재 Postman uzumango mock Server에서 구동 중이며 Test 용으로 사용 중이다.

### #103으로 선택한 날짜의 시간을 전달

```dart
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
```

위 코드는 #102에서 사용자가 선택한 날짜와 시간을 #103으로 전달하는 파트이다.

기존 uploadBooking 메소드 호출을 삭제하고 Navigaitor를 통해 PageRoute 호출하여 NextStatePage로 이동한다. 이때 인자를 tempDate로 하여 데이터를 전달한다.

이때 tempDate는 controller에 정의되어 있는 generateNewBookingForUploading() 메소드의 return 값인 bookingService 객체의 bookingStart 인스턴스를 할당하여 사용자가 선택한 시간의 시작 시간을 할당한다.

또한 기존 로직은 onTap() 시 `async` 하게 `await widget.uploadBooking()` 를 await하여 비동기 처리하였으나 기존에는 페이지 이동이 아닌 dialog를 띄우는 방식이라  `widget.uploadBooking()` 의 처리를 기다려야 했으나 변경된 로직은 다음 페이지로 데이터를 전달하고 push하는 방식이기 때문에 async하게 처리하지 않음.

controller의 generateNewBookingForUploading은 다음과 같다.

```dart
BookingService generateNewBookingForUploading() {
  final bookingDate = allBookingSlots.elementAt(selectedSlot);
  bookingService
    ..bookingStart = (bookingDate)
    ..bookingEnd =
        (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
  return bookingService;
}
```

### 휴무일 처리

휴무일 기능을 처리하기 위해 json body에 “isClosed”를 추가하였다.

isClosed은 boolean type으로 ture, false의 값을 가진다.

true : 휴무일

false : 정상 영업

isClosed를 사용하여 BookingSlot build 이전에 상태 확인을 하여 BookingSlot 생성을 통제한다.

```dart
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
    ///여기서 캘린더 하단 시간 선택 slot이 생성
final data = snapshot.requireData;
    print("booking_calendar_main in Stream data: $data");

    print('in main snapshot : ${snapshot.data.isClosed}');
//07.08 추가 isClosed의 값에 따라 BookingSlot의 생성을 관리한다.
//isClosed가 false일 경우 BookingSlot을 생성
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
// isClosed가 true일 경우 휴무일 출력
    } else {
      return const Center(child: Text('휴무일'));
    }
  },
),
```
