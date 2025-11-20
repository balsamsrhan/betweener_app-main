import 'package:betweeener_app/providers/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/controllers/auth_controller.dart';
import 'package:betweeener_app/core/util/assets.dart';
import 'package:betweeener_app/providers/user_provider.dart';
import 'package:betweeener_app/views_features/auth/login_view.dart';
import 'package:betweeener_app/views_features/main_app_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:email_validator/email_validator.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/google_button_widget.dart';
import '../widgets/secondary_button_widget.dart';
import '../widgets/primary_outlined_button_widget.dart';

class RegisterView extends StatefulWidget {
  static String id = '/registerView';

  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void submitRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final Map<String, dynamic> body = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
      };

      try {
        final user = await register(body);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUser(user);

        final linksProvider = Provider.of<LinksProvider>(context, listen: false);
        await linksProvider.loadUserLinks();

        if (mounted) {
          Navigator.pushReplacementNamed(context, MainAppView.id);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 8,
                    child: Hero(
                      tag: 'authImage',
                      child: SvgPicture.asset(AssetsData.authImage),
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomTextFormField(
                    controller: nameController,
                    hint: 'John Doe',
                    label: 'Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  CustomTextFormField(
                    controller: emailController,
                    hint: 'example@gmail.com',
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  CustomTextFormField(
                    controller: passwordController,
                    hint: 'Enter password',
                    label: 'Password',
                    password: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  CustomTextFormField(
                    controller: confirmPasswordController,
                    hint: 'Confirm password',
                    label: 'Confirm Password',
                    password: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SecondaryButtonWidget(
                    onTap: isLoading ? null : submitRegister,
                    text: isLoading ? 'REGISTERING...' : 'REGISTER',
                  ),
                  const SizedBox(height: 12),

                  Text(
                    '-  or  -',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 12),

                  PrimaryOutlinedButtonWidget(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, LoginView.id);
                    },
                    text: 'ALREADY HAVE ACCOUNT? LOGIN',
                  ),
                  const SizedBox(height: 12),

                  GoogleButtonWidget(onTap: () {}),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}