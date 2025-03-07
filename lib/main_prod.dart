import 'package:flutter/widgets.dart';
import 'package:k0sha_vpn/bootstrap.dart';
import 'package:k0sha_vpn/core/model/environment.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  return lazyBootstrap(widgetsBinding, Environment.prod);
}
