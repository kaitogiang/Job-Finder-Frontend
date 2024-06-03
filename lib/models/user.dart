class User {
  final String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String avatar;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatar
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'avatar': avatar
    };
  }

  String getImageUrl({String uri = "http://10.0.2.2:3000/"}) {
    return uri + avatar;
  }

}
