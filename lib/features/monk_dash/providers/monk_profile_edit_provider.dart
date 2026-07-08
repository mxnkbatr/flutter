import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/session_clear.dart';
import 'package:sacred_app/core/utils/media_url.dart';

class MonkProfileData {
  const MonkProfileData({
    required this.name,
    required this.temple,
    required this.bio,
    required this.categories,
    required this.services,
    this.title = '',
    this.email = '',
    this.image,
  });

  final String name;
  final String title;
  final String temple;
  final String bio;
  final List<String> categories;
  final List<MonkServiceDraft> services;
  final String email;
  final String? image;

  factory MonkProfileData.fromJson(Map<String, dynamic> json) {
    final nameVal = json['name'];
    String name;
    if (nameVal is Map) {
      name = nameVal['mn']?.toString() ?? nameVal['en']?.toString() ?? '';
    } else {
      name = nameVal?.toString() ?? '';
    }

    final titleVal = json['title'];
    String title;
    if (titleVal is Map) {
      title = titleVal['mn']?.toString() ?? titleVal['en']?.toString() ?? '';
    } else {
      title = titleVal?.toString() ?? '';
    }

    final servicesRaw = json['services'] as List<dynamic>? ?? [];
    return MonkProfileData(
      name: name,
      title: title,
      temple: json['temple'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      services: servicesRaw
          .map((e) => MonkServiceDraft.fromJson(e as Map<String, dynamic>))
          .toList(),
      email: json['email'] as String? ?? '',
      image: resolveMediaUrl(json['image'] as String?),
    );
  }
}

class MonkServiceDraft {
  MonkServiceDraft({
    this.name = '',
    this.description = '',
    this.durationMinutes = 30,
    this.price = 0,
    this.category = '',
  });

  String name;
  String description;
  int durationMinutes;
  int price;
  String category;

  factory MonkServiceDraft.fromJson(Map<String, dynamic> json) {
    final nameVal = json['name'];
    String name;
    if (nameVal is Map) {
      name = nameVal['mn']?.toString() ?? nameVal['en']?.toString() ?? '';
    } else {
      name = nameVal?.toString() ?? '';
    }
    return MonkServiceDraft(
      name: name,
      description: json['description'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      price: (json['price'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'durationMinutes': durationMinutes,
        'price': price,
        'category': category,
      };
}

final monkProfileEditProvider =
    FutureProvider.autoDispose<MonkProfileData>((ref) async {
  final res = await ref.read(apiClientProvider).get('/monk/profile');
  return MonkProfileData.fromJson(res.data as Map<String, dynamic>);
});

Future<void> saveMonkProfile(WidgetRef ref, Map<String, dynamic> data) async {
  await ref.read(apiClientProvider).put('/monk/profile', data: data);
  ref.invalidate(monkProfileEditProvider);
  invalidatePublicMonkCaches(ref);
}

Future<void> saveMonkServices(
  WidgetRef ref,
  List<MonkServiceDraft> services,
) async {
  await ref.read(apiClientProvider).put(
        '/monk/services',
        data: {
          'services': services.map((s) => s.toJson()).toList(),
        },
      );
  ref.invalidate(monkProfileEditProvider);
}
