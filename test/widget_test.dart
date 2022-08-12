// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:book_calendor_test/src/model/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:book_calendor_test/main.dart';
import 'dart:convert';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  final url = Uri.parse("https://cbb5a17f-f6ca-4c30-bd18-b01a8674952c.mock.pstmn.io");
  test('http 통신 테스트', () async{
    print("잘되나?");
    var response = await http.get(url);
    //
    expect(response.statusCode, 200);
    //
    BookingService result = BookingService.fromJson(json.decode(response.body));


    print(result.serviceDuration);
    print(result.bookingStart);
    print(result.bookingEnd);
    print(result.bookedEndList.runtimeType);
    print(result.bookedStartList.runtimeType);
    print(result.companyId);
    print(result.bookedEndList);
    print(result.bookedStartList);


  });
}
