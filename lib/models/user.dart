class User {
  String noIdentitas;
  String nama;
  String email;
  String noTelepon;
  String password;

  // Constructor
  User({
    required this.noIdentitas,
    required this.nama,
    required this.email,
    required this.noTelepon,
    required this.password,
  });

  // Method untuk serialisasi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'no_identitas': noIdentitas,
      'nama': nama,
      'email': email,
      'no_telepon': noTelepon,
      'password': password,
    };
  }

  // Method untuk deserialisasi dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      noIdentitas: json['no_identitas'],
      nama: json['nama'],
      email: json['email'],
      noTelepon: json['no_telepon'],
      password: json['password'],
    );
  }
}
