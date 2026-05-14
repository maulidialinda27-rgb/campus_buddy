import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Otomatis buka kamera/galeri atau langsung tampilkan gambar jika sudah tersedia
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
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan2Note - OCR'),
          backgroundColor: Colors.grey[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan2Note',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ambil foto atau pilih dari galeri lalu lihat hasil OCR di bawah.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
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
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Ambil Foto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImageFromGallery,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Pilih Galeri'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
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
                            color: Colors.black,
                            height: 280,
                            child: _image != null
                                ? Image.file(_image!, fit: BoxFit.cover)
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.image,
                                          size: 60,
                                          color: Colors.white24,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Preview gambar akan muncul di sini',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white38,
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
                            color: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: _recognizedText.isEmpty
                              ? const Text(
                                  'Teks hasil scan akan muncul di sini.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 15,
                                  ),
                                )
                              : SelectableText(
                                  _recognizedText,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy text'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _recognizedText.isEmpty
                                    ? null
                                    : _saveText,
                                icon: const Icon(Icons.save),
                                label: const Text('Simpan hasil scan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
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
      ),
    );
  }
}
