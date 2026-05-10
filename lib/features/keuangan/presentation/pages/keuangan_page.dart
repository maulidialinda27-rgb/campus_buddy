import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/widgets/custom_buttons.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({Key? key}) : super(key: key);

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.keuangan), elevation: 0),
      body: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fitur Manajemen Keuangan - KostBudget'),
              const Spacer(),
              CustomButton(
                label: AppStrings.tambahPengeluaran,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tambah Pengeluaran - Coming Soon'),
                    ),
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
