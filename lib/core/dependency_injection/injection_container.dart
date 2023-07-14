import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:mpac_app/core/dependency_injection/injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> setupDi() => $initGetIt(getIt);
