/// One person in the admin's People list: a `users/{uid}` profile.
class Person {
  const Person({required this.uid, this.nickname, this.createdAt});

  final String uid;
  final String? nickname;
  final DateTime? createdAt;
}
