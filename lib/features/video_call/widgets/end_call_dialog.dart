import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class EndCallDialog extends StatelessWidget {
  const EndCallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Дуудлага дуусгах уу?', style: AppText.h3),
      content: const Text(
        'Дуудлага дууссаны дараа захиалга бүрэн дууссан гэж тэмдэглэгдэнэ.',
        style: AppText.bodySmall,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Үргэлжлүүлэх'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Дуусгах'),
        ),
      ],
    );
  }
}
