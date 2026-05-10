import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/widgets/custom_buttons.dart';

class TugasPage extends StatefulWidget {
  const TugasPage({Key? key}) : super(key: key);

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tugas), elevation: 0),
      body: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fitur Manajemen Tugas - StudyMate'),
              const Spacer(),
              CustomButton(
                label: AppStrings.tambahTugas,
                onPressed: () {
                  // Implementasi nanti
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tambah Tugas - Coming Soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
