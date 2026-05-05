import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/security_illustration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_emailController.text == "ths@gmail.com" &&
        _passwordController.text == "Ths@2025") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login Successful!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final isMedium = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildNavBar(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF0F4F8), Color(0xFFE2EAF2)],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 48 : (isMedium ? 32 : 16),
                  vertical: 24,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: isWide
                        ? _buildWideLayout()
                        : _buildNarrowLayout(isMedium),
                  ),
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 12 : 24,
        vertical: isNarrow ? 10 : 14,
      ),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.secondaryLight,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLAIM AUTOMATE CHECKER',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: isNarrow ? 14 : 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Automated Claim Verification & Processing System',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: isNarrow ? 10 : 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      width: double.infinity,
      height: 4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondaryLight,
            AppColors.secondary,
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Card(
          elevation: 8,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(child: _buildIllustrationPanel()),
              Container(width: 1, color: AppColors.lightGrey),
              Expanded(child: _buildLoginFormPanel()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(bool isMedium) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMedium ? 500 : 400),
        child: Card(
          elevation: 8,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildLoginFormPanel(),
        ),
      ),
    );
  }

  Widget _buildIllustrationPanel() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F6FC), Color(0xFFE3EDF7)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SecurityIllustration(size: 240),
          const SizedBox(height: 32),
          const Text(
            'Secure Claim Verification',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Access the automated claim checking system with enhanced security and real-time verification.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              FeatureBadge(
                icon: Icons.speed_rounded,
                label: 'Quick Processing',
              ),
              FeatureBadge(
                icon: Icons.security_rounded,
                label: 'Secured Login',
              ),
              FeatureBadge(
                icon: Icons.auto_fix_high_rounded,
                label: 'Auto Verification',
              ),
              FeatureBadge(
                icon: Icons.analytics_rounded,
                label: 'Smart Analytics',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title section
            Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Welcome to CAC', style: AppTextStyles.heading2),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                'Sign in with your email and password',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Email field
            const Text('Email Address', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.validateEmail,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _emailController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    final isValid =
                        Validators.validateEmail(value.text) == null;
                    return Icon(
                      isValid
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: isValid ? AppColors.success : AppColors.error,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Password', style: AppTextStyles.label),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: Validators.validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.darkGrey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Remember me
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: const Text(
                    'Remember me',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Login button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Sign In', style: AppTextStyles.button),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Register link
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: AppTextStyles.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Register',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Text(
        '© 2026 Claim Automate Checker. All Rights Reserved.',
        style: TextStyle(
          color: AppColors.white.withValues(alpha: 0.7),
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
