import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:betweeener_app/providers/user_provider.dart';
import 'package:betweeener_app/views_features/widgets/custom_text_form_field.dart';
import 'package:betweeener_app/views_features/widgets/secondary_button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileView extends StatefulWidget {
  static const String id = '/editProfile';
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser!;
    nameController = TextEditingController(text: user.user.name);
    emailController = TextEditingController(text: user.user.email);
    phoneController = TextEditingController(text: '+970${user.user.id.toString().padLeft(9, '0')}');
    setState(() {});
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<bool> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser!;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/${user.user.id}'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        try {
          final updatedUser = User.fromJson(jsonDecode(response.body));
          await userProvider.setUser(updatedUser);
          return true;
        } catch (e) {
          final updatedUserClass = UserClass(
            id: user.user.id,
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            emailVerifiedAt: user.user.emailVerifiedAt,
            createdAt: user.user.createdAt,
            updatedAt: user.user.updatedAt,
            isActive: user.user.isActive,
            country: user.user.country,
            ip: user.user.ip,
            long: user.user.long,
            lat: user.user.lat,
          );
          userProvider.updateUser(updatedUserClass);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/300?u=${userProvider.currentUser?.user.id ?? 0}',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomTextFormField(
                label: 'Name',
                hint: 'Samy Ahmed',
                controller: nameController,
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                label: 'Email',
                hint: 'samy@example.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter your email';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                label: 'Phone',
                hint: '+970591234567',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length < 10 ? 'Invalid phone' : null,
              ),
              const SizedBox(height: 50),

              SecondaryButtonWidget(
                onTap: isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    final success = await _updateProfile();
                    setState(() => isLoading = false);

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated! 🎉'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                text: isLoading ? 'Saving...' : 'Save',
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}