import 'package:flutter/material.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brand = await BrandController.restore();
  runApp(Project360App(controller: BrandController(brand)));
}
