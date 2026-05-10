import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/widgets/custom_buttons.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profil), elevation: 0),
      body: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fitur Profil Pengguna'),
              const SizedBox(height: 16),
              const Text('Informasi Akun'),
              const SizedBox(height: 24),
              const Text('Pengaturan'),
              const Spacer(),
              CustomButton(
                label: 'Simpan Profil',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil - Coming Soon')),
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
