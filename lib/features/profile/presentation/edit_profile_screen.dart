import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/auth_phone.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/profile/providers/user_profile_provider.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  String _email = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _load(UserProfile profile) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = profile.name;
    _phoneCtrl.text = profile.phone;
    _email = profile.email;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нэрээ оруулна уу')),
      );
      return;
    }

    final phoneRaw = _phoneCtrl.text.trim();
    if (phoneRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Утасны дугаар оруулна уу')),
      );
      return;
    }
    if (!AuthPhone.isValid(phoneRaw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Зөв утасны дугаар оруулна уу')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).put(
            '/users/profile',
            data: {
              'name': name,
              'phone': AuthPhone.normalize(phoneRaw),
            },
          );
      await ref.read(authStateProvider.notifier).refreshProfile();
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профайл хадгалагдлаа'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatUserError(e)),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return PremiumLayeredScaffold(
      title: 'Бүртгэл засварлах',
      showBackButton: true,
      useNativeNavBar: true,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
        error: (e, _) => Center(child: Text(formatUserError(e))),
        data: (profile) {
          _load(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SacredInput(
                  controller: _nameCtrl,
                  label: 'Нэр',
                  hint: 'Таны нэр',
                ),
                const SizedBox(height: 16),
                SacredInput(
                  controller: _phoneCtrl,
                  label: 'Утасны дугаар',
                  hint: '9900 0000',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'И-мэйл',
                      style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPri,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.creamBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSub),
                      ),
                      child: Text(
                        _email.isEmpty ? 'Бүртгээгүй' : _email,
                        style: AppText.body.copyWith(color: AppColors.textSec),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _email.isEmpty
                      ? 'И-мэйл бүртгэлгүй. Утасны дугаараар нэвтрэнэ.'
                      : 'И-мэйл хаягийг аюулгүй байдлын үүднээс энд өөрчлөх боломжгүй.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 28),
                SacredButton(
                  label: _saving ? 'Хадгалж байна...' : 'Хадгалах',
                  onTap: _saving ? null : _save,
                  sunShadow: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
