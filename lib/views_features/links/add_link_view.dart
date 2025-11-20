import 'package:betweeener_app/providers/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/views_features/widgets/custom_text_form_field.dart';
import 'package:betweeener_app/views_features/widgets/secondary_button_widget.dart';

class AddLinkView extends StatefulWidget {
  static const id = '/addLink';
  const AddLinkView({super.key});

  @override
  State<AddLinkView> createState() => _AddLinkViewState();
}

class _AddLinkViewState extends State<AddLinkView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _addLink() async {
    if (formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final linksProvider = Provider.of<LinksProvider>(context, listen: false);

      try {
        await linksProvider.addLink({
          'title': titleController.text.trim(),
          'link': linkController.text.trim(),
          'username': usernameController.text.trim(),
          'isActive': '1',
        });

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: const Text('Add New Link'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextFormField(
                label: 'Title',
                hint: 'Instagram, Twitter, etc.',
                controller: titleController,
                validator: (title) {
                  if (title == null || title.isEmpty) {
                    return 'Please enter link title';
                  }
                  if (title.length < 2) {
                    return 'Title must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                label: 'Link URL',
                hint: 'https://instagram.com/username',
                controller: linkController,
                keyboardType: TextInputType.url,
                validator: (link) {
                  if (link == null || link.isEmpty) {
                    return 'Please enter link URL';
                  }
                  if (!_isValidUrl(link)) {
                    return 'Please enter a valid URL (start with http:// or https://)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                label: 'Username (Optional)',
                hint: 'yourusername',
                controller: usernameController,
              ),
              const SizedBox(height: 8),

              Text(
                'Username will be displayed instead of the full link',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),

              SecondaryButtonWidget(
                onTap: _isSubmitting ? null : _addLink,
                text: _isSubmitting ? 'Adding...' : 'Add Link',
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    linkController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}