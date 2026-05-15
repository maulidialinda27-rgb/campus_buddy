import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/widgets/custom_buttons.dart';
import 'package:campus_buddy/features/scan/presentation/scan_to_note_page.dart';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCameraAndNavigate() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanToNotePage(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.scan), elevation: 0),
      body: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fitur Scan & Catatan - Scan2Note'),
              const SizedBox(height: 20),
              const Text(
                'Ambil foto atau pilih dari galeri untuk OCR:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: AppStrings.ambilFoto,
                      onPressed: _openCameraAndNavigate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      label: AppStrings.pilihDariGaleri,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ScanToNotePage(autoOpenGallery: true),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
