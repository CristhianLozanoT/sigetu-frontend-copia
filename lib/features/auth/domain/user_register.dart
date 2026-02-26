class UserRegister {
  final String email;
  final String fullName;
  final String password;
  final String academicProgram;

  UserRegister({
    required this.email,
    required this.fullName,
    required this.password,
    required this.academicProgram,
  });

  Map<String, dynamic> toJson() => {
        "email": email,
        "full_name": fullName,
        "password": password,
        "programa_academico": academicProgram,
      };
}