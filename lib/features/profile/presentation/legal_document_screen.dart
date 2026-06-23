import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

enum LegalDocumentType { terms, privacy }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final LegalDocumentType type;

  String get _title => switch (type) {
        LegalDocumentType.terms => 'Үйлчилгээний нөхцөл',
        LegalDocumentType.privacy => 'Нууцлалын бодлого',
      };

  List<String> get _sections => switch (type) {
        LegalDocumentType.terms => _termsSections,
        LegalDocumentType.privacy => _privacySections,
      };

  static const _termsSections = [
    '1. Ерөнхий\nGevabal.mn платформ нь лам, багш нартай онлайн уулзалт, зөвлөгөө авах үйлчилгээг санал болгодог. Апп ашигласнаар та энэхүү нөхцөлийг хүлээн зөвшөөрсөн гэж үзнэ.',
    '2. Бүртгэл\nХэрэглэгч бүрэн, үнэн зөв мэдээлэл өгөх үүрэгтэй. Нэг хүн нэг бүртгэл үүсгэнэ. Бүртгэлийн нууц үгийг бусдад дамжуулахгүй байна.',
    '3. Захиалга ба төлбөр\nЗахиалга лам баталгаажуулсны дараа төлбөр төлөгдөнө. Төлбөр амжилттай болсны дараа захиалга идэвхжинэ. Буцаалтын нөхцөл QPay болон банкны дүрмээр зохицуулагдана.',
    '4. Видео дуудлага\nУулзалтын цагт платформын видео холболтыг ашиглана. Хэрэглэгч камер, микрофоны зөвшөөрөл өгөх, интернет холболтоо хангалттай байлгах үүрэгтэй.',
    '5. Хариуцлага\nПлатформ нь лам, багш нарын мэргэжлийн зөвлөгөөний агуулга, үр дүнг баталгаажуулахгүй. Үйлчилгээ нь сүнслэг, зөвлөгөөний зорилгоор үзүүлнэ.',
    '6. Цуцлалт\nБаталгаажаагүй захиалгыг цуцлах боломжтой. Баталгаажсан захиалгын цуцлалтыг дэмжлэгийн багтай зөвлөн шийдвэрлэнэ.',
  ];

  static const _privacySections = [
    '1. Цуглуулж буй мэдээлэл\nБид таны нэр, и-мэйл, утасны дугаар, захиалгын түүх, төлбөрийн статус, FCM мэдэгдлийн token зэрэг мэдээллийг цуглуулна.',
    '2. Ашиглалтын зорилго\nМэдээллийг захиалга баталгаажуулах, видео дуудлага холбох, төлбөр баталгаажуулах, мэдэгдэл илгээх зорилгоор ашиглана.',
    '3. Хадгалалт\nМэдээлэл аюулгүй сервер дээр хадгалагдана. Нууц үг hash хэлбэрээр хадгалагдана.',
    '4. Гуравдагч этгээд\nQPay төлбөр, LiveKit видео холболт, Firebase push мэдэгдэл зэрэг үйлчилгээний түншүүдтэй хязгаарлагдмал мэдээлэл хуваалцана.',
    '5. Таны эрх\nТа өөрийн профайл мэдээллийг засах, мэдэгдлийн тохиргоог удирдах эрхтэй. Профайл → Бүртгэл устгах цэснээс бүртгэлээ бүрмөсөн устгаж болно.',
    '6. Холбоо барих\nНууцлалтай холбоотой асуултыг support@gevabal.mn хаягаар илгээнэ үү.',
  ];

  @override
  Widget build(BuildContext context) {
    return PremiumLayeredScaffold(
      title: _title,
      showBackButton: true,
      useNativeNavBar: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Сүүлд шинэчлэгдсэн: 2026 оны 6 сар',
            style: AppText.caption.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          ..._sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                section,
                style: AppText.bodySmall.copyWith(
                  color: AppColors.textPri,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
