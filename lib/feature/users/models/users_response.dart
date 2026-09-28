class UsersResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<ApiUser> data;

  const UsersResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((item) => ApiUser.fromJson(item as Map<String, dynamic>))
        .toList();

    return UsersResponse(
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 5,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      data: list,
    );
  }
}

class ApiUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const ApiUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }

  @override
  String toString() => 'ApiUser(id: $id, name: $fullName, email: $email)';
}
