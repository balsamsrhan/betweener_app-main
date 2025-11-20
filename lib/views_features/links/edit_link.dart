import 'package:betweeener_app/providers/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/views_features/widgets/custom_text_form_field.dart';
import 'package:betweeener_app/views_features/widgets/secondary_button_widget.dart';

class EditLinkView extends StatefulWidget {
  final LinkElement link;
  static const String id = '/editLink';

  const EditLinkView({super.key, required this.link});

  @override
  State<EditLinkView> createState() => _EditLinkViewState();
}

class _EditLinkViewState extends State<EditLinkView> {
  late TextEditingController titleController;
  late TextEditingController linkController;
  late TextEditingController usernameController;

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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.link.title);
    linkController = TextEditingController(text: widget.link.link);
    usernameController = TextEditingController(text: widget.link.username ?? '');
  }

  Future<void> _updateLink() async {
    if (formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final linksProvider = Provider.of<LinksProvider>(context, listen: false);

      try {
        await linksProvider.updateLink(widget.link.id, {
          'title': titleController.text.trim(),
          'link': linkController.text.trim(),
          'username': usernameController.text.trim(),
          'isActive': widget.link.isActive.toString(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link updated successfully! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
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
        title: const Text('Edit Link'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 2) {
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a link';
                  }
                  if (!_isValidUrl(value)) {
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
              const SizedBox(height: 50),

              SecondaryButtonWidget(
                onTap: _isSubmitting ? null : _updateLink,
                text: _isSubmitting ? 'Saving...' : 'Save Changes',
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