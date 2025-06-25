class UserProfile {
  final String noIdentitas;
  final String nama;
  final String email;
  final String phone;
  final String balance;

  UserProfile({
    required this.noIdentitas,
    required this.nama,
    required this.email,
    required this.phone,
    required this.balance,
  });

  // Fungsi untuk deserialisasi dari JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      noIdentitas: json['data']['no_identitas'],
      nama: json['data']['nama'],
      email: json['data']['email'],
      phone: json['data']['no_telepon'],
      balance: json['data']['saldo'],
    );
  }
}
