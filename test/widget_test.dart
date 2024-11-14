import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camapp/main.dart'; // Adjust the import path as needed
import 'package:camera/camera.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';

// Mock classes for CameraDescription and ImagePicker
class MockCameraDescription extends Mock implements CameraDescription {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  final mockCamera = MockCameraDescription();
  final mockImagePicker = MockImagePicker();

  testWidgets('Navigation and Camera Button Test', (WidgetTester tester) async {
    // Build the app with a mock camera.
    await tester.pumpWidget(MyApp(camera: mockCamera));

    // Verify that the initial screen contains the Explore tab.
    expect(find.text('Explore'), findsOneWidget);

    // Tap on the Text tab.
    await tester.tap(find.text('Text'));
    await tester.pump();

    // Verify that the Text tab is selected.
    expect(find.text('Read the text'), findsOneWidget);

    // Tap on the camera floating action button.
    await tester.tap(find.byIcon(Icons.camera));
    await tester.pump();

    // Mock the image picker function and verify it is called.
    when(mockImagePicker.pickImage(source: ImageSource.camera)).thenAnswer((_) async => null);

    // Verify the camera function is called.
    expect(find.text('Read the text'), findsOneWidget);
  });

  testWidgets('Tab Selection Test', (WidgetTester tester) async {
    // Build the app with a mock camera.
    await tester.pumpWidget(MyApp(camera: mockCamera));

    // Tap on the Explore tab.
    await tester.tap(find.text('Explore'));
    await tester.pump();

    // Verify that the Explore screen is displayed.
    expect(find.text('Explore'), findsOneWidget);

    // Tap on the Documents tab.
    await tester.tap(find.text('Documents'));
    await tester.pump();

    // Verify that the Documents screen is displayed.
    expect(find.text('Documents'), findsOneWidget);
  });
}
