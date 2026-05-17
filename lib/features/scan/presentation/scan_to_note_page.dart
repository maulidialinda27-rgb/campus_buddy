import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

class ScanToNotePage extends StatefulWidget {
  final bool autoOpenCamera;
  final bool autoOpenGallery;
  final String? imagePath;

  const ScanToNotePage({
    super.key,
    this.autoOpenCamera = false,
    this.autoOpenGallery = false,
    this.imagePath,
  });

  @override
  State<ScanToNotePage> createState() => _ScanToNotePageState();
}

class _ScanToNotePageState extends State<ScanToNotePage> {
  File? _image;
  String _recognizedText = '';
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.imagePath != null) {
        setState(() {
          _image = File(widget.imagePath!);
        });
        await _recognizeText();
      } else if (widget.autoOpenCamera) {
        await _pickImageFromCamera();
      } else if (widget.autoOpenGallery) {
        await _pickImageFromGallery();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        await _recognizeText();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        await _recognizeText();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _recognizeText() async {
    if (_image == null) return;

    try {
      final inputImage = InputImage.fromFile(_image!);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (!mounted) return;
      setState(() {
        _recognizedText = recognizedText.text;
        _textController.text = _recognizedText;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error recognizing text: $e')));
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_scan_text', _textController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Text saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Scan2Note - OCR',
          style: TextStyle(
            color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        iconTheme: IconThemeData(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan2Note',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ambil foto atau pilih dari galeri lalu lihat hasil OCR di bawah.',
                style: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImageFromCamera,
                              icon: Icon(Icons.camera_alt),
                              label: Text('Ambil Foto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: Icon(Icons.photo_library),
                              label: Text('Pilih Galeri'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          height: 280,
                          child: _image != null
                              ? Image.file(_image!, fit: BoxFit.cover)
                              : Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 60,
                                        color: AppColors.gray300,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Preview gambar akan muncul di sini',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hasil OCR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: _recognizedText.isEmpty
                            ? Text(
                                'Teks hasil scan akan muncul di sini.',
                                style: TextStyle(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                                  fontSize: 15,
                                ),
                              )
                            : SelectableText(
                                _recognizedText,
                                style: TextStyle(
                                  color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _recognizedText.isEmpty
                                  ? null
                                  : _copyText,
                              icon: Icon(Icons.copy),
                              label: Text('Copy text'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gray500,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _recognizedText.isEmpty
                                  ? null
                                  : _saveText,
                              icon: Icon(Icons.save),
                              label: Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
