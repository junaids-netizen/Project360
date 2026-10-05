import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/features/bank/bank_preview_app.dart';

/// Until [tool/vendor_vera_design.sh] runs, previews use the in-repo bank shell.
Widget buildPreviewAppImpl({required GoRouter router}) =>
    BankPreviewApp(router: router);
