import 'package:flutter/material.dart';
import 'package:flutter_artefak/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fixed colors without dark mode
    final backgroundColor = const Color(0xFFFAFAFA);
    final cardColor = Colors.white;
    final textColor = const Color(0xFF2D3748);
    final subtitleColor = const Color(0xFF718096);
    final shadowColor = Colors.black26;
    final primaryColor = const Color(0xFF4299E1);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.jpg', 
                      height: 80,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Title
                        Text(
                          'VokasiTera IT DEL',
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        
                        // Subtitle
                        Text(
                          'Martuhan - Marroha - Marbisuk',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Username Field
                        TextField(
                          controller: usernameController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: subtitleColor),
                            prefixIcon: Icon(Icons.person, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: subtitleColor),
                            prefixIcon: Icon(Icons.lock, color: primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: subtitleColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fitur lupa password akan segera hadir'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login Button with Integrated Loading
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              try {
                                final response = await ApiService.login(
                                  usernameController.text,
                                  passwordController.text,
                                );
                                
                                setState(() {
                                  _isLoading = false;
                                });
                                
                                if (response['success']) {
                                  Navigator.pushReplacementNamed(context, '/main');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message'] ?? 'Login gagal'),
                                      backgroundColor: Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              disabledBackgroundColor: primaryColor.withOpacity(0.7),
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Logging in...',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Log in',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Version Text
                  Text(
                    'Vokasi Tera v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}