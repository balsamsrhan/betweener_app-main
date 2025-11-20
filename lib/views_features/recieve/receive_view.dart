import 'dart:io';
import 'package:betweeener_app/core/helpers/token_helper.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class ReceiveView extends StatefulWidget {
  static const String id = '/receiveView';
  const ReceiveView({super.key});

  @override
  State<ReceiveView> createState() => _ReceiveViewState();
}

class _ReceiveViewState extends State<ReceiveView> {
  UserClass? scannedUser;
  List<LinkElement> scannedLinks = [];
  bool isProcessing = false;

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final qrData = await _decodeQRFromImage(File(pickedFile.path));
      if (qrData != null && qrData.startsWith('betweener://user/')) {
        await _processQR(qrData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid QR code found in image!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<String?> _decodeQRFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final barcodeScanner = BarcodeScanner(
      formats: [BarcodeFormat.qrCode],
    );
    final barcodes = await barcodeScanner.processImage(inputImage);
    barcodeScanner.close();
    return barcodes.isNotEmpty ? barcodes.first.rawValue : null;
  }

  Future<void> _processQR(String qrData) async {
    final userId = qrData.split('/').last;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {'Authorization': 'Bearer ${await getToken()}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        scannedUser = UserClass.fromJson(data['user']);
        scannedLinks = (data['links'] as List)
            .map((l) => LinkElement.fromJson(l))
            .toList();

        if (mounted) {
          setState(() {});
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: const Text('Scan QR'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing)
              const CircularProgressIndicator()
            else if (scannedUser == null)
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.image),
                label: const Text('Pick QR Image from Gallery'),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=${scannedUser!.id}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        scannedUser!.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        scannedUser!.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Now following ${scannedUser!.name}!')),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Follow'),
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            final linksText = scannedLinks.map((l) => '${l.title}: ${l.link}').join('\n');
                            Clipboard.setData(ClipboardData(text: linksText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Links copied!')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Links'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...scannedLinks.map((link) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kLightSecondaryColor,
                        child: Text(link.title[0]),
                      ),
                      title: Text(link.title),
                      subtitle: SelectableText(link.link),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => launchUrl(Uri.parse(link.link)),
                      ),
                    )),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: scannedUser != null
          ? FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          setState(() {
            scannedUser = null;
            scannedLinks = [];
          });
        },
      )
          : null,
    );
  }
}