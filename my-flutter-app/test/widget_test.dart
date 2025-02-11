import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/screens/splash_screen.dart';
import 'package:my_flutter_app/screens/home_screen.dart';

void main() {
  testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SplashScreen()));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Your Logo'), findsOneWidget); // Replace with actual logo text
  });

  testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Home Screen Content'), findsOneWidget); // Replace with actual content
  });
}