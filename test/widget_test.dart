import 'package:flutter_test/flutter_test.dart';
import 'package:grin_demo/feature/users/models/users_response.dart';

void main() {
  test('ApiUser model parses JSON correctly', () {
    final json = {
      'id': 1,
      'email': 'george.bluth@reqres.in',
      'first_name': 'George',
      'last_name': 'Bluth',
      'avatar': 'https://reqres.in/img/faces/1-image.jpg',
    };

    final user = ApiUser.fromJson(json);

    expect(user.id, 1);
    expect(user.email, 'george.bluth@reqres.in');
    expect(user.fullName, 'George Bluth');
    expect(user.avatar, 'https://reqres.in/img/faces/1-image.jpg');
  });
}
