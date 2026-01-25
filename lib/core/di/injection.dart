import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
  // Break circular dependency by setting auth repository on API client after both are created
  final apiClient = getIt<ApiClient>();
  final authRepo = getIt<AuthRepository>();
  apiClient.setAuthRepository(authRepo);
}
