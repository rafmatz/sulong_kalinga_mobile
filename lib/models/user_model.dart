class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final int? roleId;
  final String? photo;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.roleId,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      mobile: json['mobile'],
      roleId: json['role_id'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'role_id': roleId,
      'photo': photo,
    };
  }

  String get fullName => '$firstName $lastName';
}