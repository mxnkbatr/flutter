import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/main.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState();
}

void main() {
  testWidgets('App boots to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_FakeAuthNotifier.new),
        ],
        child: const SacredApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sacred'), findsOneWidget);
    expect(find.text('Нэвтрэх'), findsWidgets);
  });
}
