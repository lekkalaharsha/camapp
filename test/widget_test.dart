import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camapp/main.dart'; // Adjust the import path to match your project structure
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('Navigation and Camera Button Test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp(camera: null,));

    // Verify that the initial screen is displayed (Explore Screen).
    expect(find.text('Explore Screen'), findsOneWidget);

    // Tap on the Text tab.
    await tester.tap(find.text('Text'));
    await tester.pump();

    // Verify that the Text screen is displayed.
    expect(find.text('Text Screen'), findsOneWidget);

    // Tap on the camera floating action button.
    await tester.tap(find.byIcon(Icons.camera));
    await tester.pump();

    // Verify that the camera function is called and the chat screen is displayed.
    // Note: This requires mocking the ImagePicker or assuming the function works.
    expect(find.text('Read the text'), findsOneWidget);
  });

  testWidgets('Tab Selection Test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Tap on the Explore tab.
    await tester.tap(find.text('Explore'));
    await tester.pump();

    // Verify that the Explore screen is displayed.
    expect(find.text('Explore Screen'), findsOneWidget);

    // Tap on the Documents tab.
    await tester.tap(find.text('Documents'));
    await tester.pump();

    // Verify that the Documents screen is displayed.
    expect(find.text('Documents Screen'), findsOneWidget);
  });
}
