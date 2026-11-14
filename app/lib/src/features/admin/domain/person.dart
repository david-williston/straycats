/// One person in the admin's People list: a `users/{uid}` profile.
class Person {
  const Person({required this.uid, this.createdAt});

  final String uid;
  final DateTime? createdAt;
}
