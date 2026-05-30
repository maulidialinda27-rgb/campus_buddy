import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/features/catatan/data/models/catatan_model.dart';
import 'package:campus_buddy/services/catatan_service.dart';
import 'package:intl/intl.dart';

class CatatanColors {
  static const Color primary = Color(0xFF7B61FF);
  static const Color dark = Color(0xFF5B3DF5);
  static const Color light = Color(0xFFA78BFA);
  static const Color background = Color(0xFFF8F9FC);
}

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  final CatatanService _service = CatatanService();
  List<CatatanModel> _catatan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatatan();
  }

  Future<void> _loadCatatan() async {
    final data = await _service.getAllCatatan();
    if (mounted) {
      setState(() {
        _catatan = data;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  Future<void> _openForm({CatatanModel? existing}) async {
    final judulCtrl = TextEditingController(text: existing?.judul ?? '');
    final isiCtrl = TextEditingController(text: existing?.isi ?? '');
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    existing == null ? 'Catatan Baru' : 'Edit Catatan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'PlusJakartaSans',
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul
                  TextFormField(
                    controller: judulCtrl,
                    autofocus: true,
                    cursorColor: CatatanColors.primary,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Judul Catatan',
                      labelStyle: TextStyle(
                        color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                      ),
                      floatingLabelStyle: const TextStyle(color: CatatanColors.primary, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: isDark ? AppColors.darkBg : AppColors.gray50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: CatatanColors.primary, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.title_rounded, color: CatatanColors.primary),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // Isi
                  TextFormField(
                    controller: isiCtrl,
                    maxLines: 6,
                    cursorColor: CatatanColors.primary,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Isi Catatan',
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                        color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                      ),
                      floatingLabelStyle: const TextStyle(color: CatatanColors.primary, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: isDark ? AppColors.darkBg : AppColors.gray50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: CatatanColors.primary, width: 2),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: Icon(Icons.notes_rounded, color: CatatanColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CatatanColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (formKey.currentState?.validate() != true) return;
                        final now = DateTime.now();
                        if (existing == null) {
                          await _service.insertCatatan(CatatanModel(
                            id: '${now.millisecondsSinceEpoch}',
                            judul: judulCtrl.text.trim(),
                            isi: isiCtrl.text.trim(),
                            dibuatPada: now,
                            diperbaruidPada: now,
                          ));
                        } else {
                          await _service.updateCatatan(existing.copyWith(
                            judul: judulCtrl.text.trim(),
                            isi: isiCtrl.text.trim(),
                            diperbaruidPada: now,
                          ));
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _loadCatatan();
                      },
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: Text(
                        existing == null ? 'Simpan Catatan' : 'Simpan Perubahan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CatatanColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(CatatanModel catatan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
          ),
          elevation: 4,
          title: Text(
            'Hapus Catatan?',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          content: Text(
            '"${catatan.judul}" akan dihapus secara permanen.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(fontFamily: 'PlusJakartaSans')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColors.error, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _service.deleteCatatan(catatan.id);
      await _loadCatatan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : CatatanColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : CatatanColors.background,
            elevation: 0,
            pinned: true,
            iconTheme: const IconThemeData(
              color: CatatanColors.primary,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark ? CatatanColors.dark.withValues(alpha: 0.1) : CatatanColors.light.withValues(alpha: 0.15),
                      bgColor,
                    ],
                  ),
                ),
              ),
            ),
            title: Text(
              'Catatan',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                fontSize: 26,
                letterSpacing: 0.2,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(color: CatatanColors.primary),
                    ),
                  )
                : _catatan.isEmpty
                    ? SizedBox(
                        height: 400,
                        child: _buildEmptyState(isDark),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _catatan.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _catatan[index];
                          return _buildCatatanCard(item, isDark);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CatatanColors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          backgroundColor: CatatanColors.primary,
          elevation: 0,
          hoverElevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Catatan Baru',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: CatatanColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sticky_note_2_rounded,
              size: 64,
              color: CatatanColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada catatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'PlusJakartaSans',
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk tombol + untuk membuat\ncatatan pertama Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              fontFamily: 'PlusJakartaSans',
              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanCard(CatatanModel item, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openForm(existing: item),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CatatanColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sticky_note_2_rounded, color: CatatanColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.judul,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlusJakartaSans',
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: AppColors.error.withValues(alpha: 0.8), size: 22),
                    onPressed: () => _confirmDelete(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (item.isi.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  item.isi,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'PlusJakartaSans',
                    color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.darkSubText : AppColors.gray400),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.diperbaruidPada),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'PlusJakartaSans',
                      color: isDark ? AppColors.darkSubText : AppColors.gray400,
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
