class AuthService {
  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'test@test.com' && password == 'password') {
      return;
    }
    throw Exception('Invalid credentials');
  }

  Future<void> signup(String email, String password, String name) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    return;
  }
}

