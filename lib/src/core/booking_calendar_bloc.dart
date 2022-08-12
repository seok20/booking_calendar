import 'package:book_calendor_test/src/model/booking_service.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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