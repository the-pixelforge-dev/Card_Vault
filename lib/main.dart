import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'application/core_providers.dart';
import 'bootstrap.dart';

Future<void> main() async {
  final dependencies = await bootstrap();

  runApp(
    ProviderScope(
      overrides: [
        appDependenciesProvider.overrideWithValue(dependencies),
      ],
      child: const CardVaultApp(),
    ),
  );
}
