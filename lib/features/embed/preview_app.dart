import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'preview_app.impl.dart';

/// Bank demo or vendored Vera Design shell for pitch / prototype previews.
Widget buildPreviewApp({required GoRouter router}) =>
    buildPreviewAppImpl(router: router);
