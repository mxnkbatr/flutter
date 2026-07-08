import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _items = [
    _FaqItem(
      question: 'Ламтай хэрхэн холбогдох вэ?',
      answer:
          'Нүүр хуудас эсвэл хайлт хэсгээс лам сонгож, үйлчилгээ болон цаг сонгосны дараа захиалга илгээнэ. Лам баталгаажуулсны дараа төлбөр төлж, төлөвлөсөн цагтаа видео дуудлагаар холбогдоно.',
    ),
    _FaqItem(
      question: 'Төлбөрийн нөхцөл ямар вэ?',
      answer:
          'QPay QR кодоор төлбөр төлнө. Төлбөр амжилттай болсны дараа захиалга идэвхжинэ.',
    ),
    _FaqItem(
      question: 'Захиалга хэзээ баталгаажих вэ?',
      answer:
          'Захиалга илгээсний дараа лам танилцан баталгаажуулна. Төлбөр төлсний дараа таны захиалга баталгаажсан төлөвт шилжин, уулзалтын цагт видео дуудлага эхлүүлэх боломжтой болно.',
    ),
    _FaqItem(
      question: 'Видео дуудлага хэрхэн ажиллах вэ?',
      answer:
          'Төлөвлөсөн цаг ирэхэд мэдэгдэл ирнэ. «Оруулах» товч дарж камер, микрофоны зөвшөөрөл өгснөөр ламтайгаа шууд холбогдоно.',
    ),
    _FaqItem(
      question: 'Захиалга цуцлах боломжтой юу?',
      answer:
          'Баталгаажаагүй захиалгыг цуцлах боломжтой. Баталгаажсан захиалгын хувьд лам эсвэл дэмжлэгийн багтай холбогдоно уу.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PremiumLayeredScaffold(
      title: 'Түгээмэл асуултууд',
      showBackButton: true,
      useNativeNavBar: true,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            decoration: MinimalStyle.card(radius: 16),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                iconColor: AppColors.orange,
                collapsedIconColor: AppColors.textHint,
                title: Text(
                  item.question,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.answer,
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.textSec,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
