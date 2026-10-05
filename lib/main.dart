import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/glass_tab/native_glass_availability.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeGlassAvailability.initialize();
  CupertinoNative.useNativeViews = NativeGlassAvailability.isAvailable;
  final brand = await BrandController.restore();
  runApp(Project360App(controller: BrandController(brand)));
}
