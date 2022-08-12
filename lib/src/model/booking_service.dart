class BookingService {

  ///The name of the currently selected Service
  final int companyId;

  ///The duration of the currently selected Service

  final int serviceDuration;

  bool isClosed;


  ///The selected booking slot's starting time
  DateTime bookingStart;

  ///The selected booking slot's ending time
  DateTime bookingEnd;

  ///07.01 추가 BookedDateList[] 추가함
  ///해당하는 업체의 예약된 시간 배열을 담기 위해 선언
  List<DateTime>? bookedStartList;

  List<DateTime>? bookedEndList;



  BookingService({
    // this.userEmail,
    // this.userPhoneNumber,
    // this.userId,
    // this.userName,
    required this.isClosed,
    required this.bookingStart,
    required this.bookingEnd,
    required this.serviceDuration,
    // this.serviceId,
    required this.companyId,
    // this.servicePrice,
    this.bookedStartList,
    this.bookedEndList
  });

  BookingService.fromJson(Map<String, dynamic> json)
      :
        // userEmail = json['userEmail'] as String?,
        // userPhoneNumber = json['userPhoneNumber'] as String?,
        // userId = json['userId'] as String?,
        // userName = json['userName'] as String?,
        isClosed = json['isClosed'] as bool,
        bookingStart = DateTime.parse(json['bookingStart'] as String),
        bookingEnd = DateTime.parse(json['bookingEnd'] as String),
        serviceDuration = json['serviceDuration'] as int,
        // serviceId = json['serviceId'] as String?,
        companyId = json['companyId'] as int,
        bookedStartList = List<DateTime>.from(json['bookedStartList'].map((data)=> DateTime.parse(data))),
        // bookedStartList = json['bookedStartList'].cast<DateTime>(),
        bookedEndList = List<DateTime>.from(json['bookedEndList'].map((data)=> DateTime.parse(data)));
        // servicePrice = json['servicePrice'] as int?;


  Map<String, dynamic> toJson() => {
        // 'userId': userId,
        // 'userName': userName,
        // 'userEmail': userEmail,
        // 'userPhoneNumber': userPhoneNumber,
        // 'serviceId': serviceId,
        'serviceName': companyId,
        // 'servicePrice': servicePrice,
        'bookingStart': bookingStart.toIso8601String(),
        'bookingEnd': bookingEnd.toIso8601String(),
      };
}
