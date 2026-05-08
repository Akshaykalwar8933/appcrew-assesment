import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/services/network_service.dart';
import '../../../app/widgets/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/notes_controller.dart';
import 'add_edit_note_view.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final NotesController notesController = Get.find<NotesController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes App',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            Text(
              authController.currentUserEmail,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.textLight,
                fontFamily: 'Georgia',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded,
                color: AppTheme.textDark, size: 22),
            tooltip: 'Logout',
          ),
          SizedBox(width: 8.w),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          notesController.prepareForAdd();
          Get.to(() => const AddEditNoteView(isEdit: false));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Note',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [

          // ── Search Bar ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
            child: Obx(() => TextField(
              controller: notesController.searchController,
              style: const TextStyle(
                  color: AppTheme.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by title or content...',
                hintStyle: const TextStyle(
                    color: AppTheme.textLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textLight, size: 20),
                // Show ✕ only when user has typed something
                suffixIcon: notesController.isSearchActive.value
                    ? GestureDetector(
                  onTap: notesController.clearSearch,
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textLight, size: 20),
                )
                    : null,
                filled: true,
                fillColor: AppTheme.cardBg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                      color: AppTheme.primary, width: 1.5),
                ),
              ),
            )),
          ),

          // ── Offline Banner ────────────────────────────────────────
          Obx(() {
            final offline =
            !ConnectivityService.instance.isConnected.value;
            if (!offline) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              color: const Color(0xFF1A1A2E),
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8.w),
                  const Expanded(
                    child: Text(
                      'You\'re offline. Notes are read-only until reconnected.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Notes List ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              // Waiting for first Firestore response
              if (notesController.isFirstLoad.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation(AppTheme.accent),
                    strokeWidth: 2.5,
                  ),
                );
              }

              // Firestore returned an error
              if (notesController.hasFirestoreError.value) {
                return _buildErrorState();
              }

              final notes = notesController.filteredNotes;

              // Search is active but nothing matched
              if (notesController.isSearchActive.value && notes.isEmpty) {
                return _buildNoResultsState(
                    notesController.searchController.text.trim());
              }

              // No notes exist at all
              if (notes.isEmpty) {
                return _buildEmptyState();
              }

              // Render notes list
              return RefreshIndicator(
                onRefresh: notesController.refreshNotes,
                color: AppTheme.accent,
                backgroundColor: AppTheme.cardBg,
                strokeWidth: 2.5,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return _NoteCard(
                      data: notes[index],
                      notesController: notesController,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Empty states ──────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: const Icon(Icons.edit_note_rounded,
                size: 40, color: AppTheme.textLight),
          ),
          SizedBox(height: 20.h),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          const Text(
            'Tap the button below to create\nyour first note.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textLight, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: AppTheme.textLight),
          ),
          SizedBox(height: 20.h),
          const Text(
            'No results found',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No notes match "$query".\nTry a different keyword.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.textLight, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: const Icon(Icons.cloud_off_rounded,
                size: 40, color: AppTheme.accent),
          ),
          SizedBox(height: 20.h),
          const Text(
            'Could not load notes',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          const Text(
            'Check your internet connection\nand try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textLight, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Logout dialog ─────────────────────────────────────────────────

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: const Text(
          'You will be taken back to the login screen.',
          style: TextStyle(color: AppTheme.textLight, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textLight)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: const Text('Sign out',
                style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Note Card ──────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final NotesController notesController;

  const _NoteCard({required this.data, required this.notesController});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = (timestamp as dynamic).toDate() as DateTime;
      return DateFormat('MMM d, y').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            notesController.prepareForEdit(
              data['title'] as String,
              data['content'] as String,
            );
            Get.to(() => AddEditNoteView(
              isEdit: true,
              docId: data['id'] as String,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['title'] as String? ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    _NoteMenu(
                      docId: data['id'] as String,
                      title: data['title'] as String,
                      content: data['content'] as String,
                      notesController: notesController,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data['content'] as String? ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(data['updated_at']),
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Note Popup Menu ────────────────────────────────────────────────────────────

class _NoteMenu extends StatelessWidget {
  final String docId;
  final String title;
  final String content;
  final NotesController notesController;

  const _NoteMenu({
    required this.docId,
    required this.title,
    required this.content,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          color: AppTheme.textLight, size: 20),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.cardBg,
      onSelected: (value) {
        if (value == 'edit') {
          notesController.prepareForEdit(title, content);
          Get.to(() => AddEditNoteView(isEdit: true, docId: docId));
        } else if (value == 'delete') {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppTheme.textDark),
              SizedBox(width: 10),
              Text('Edit', style: TextStyle(color: AppTheme.textDark)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppTheme.accent),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: AppTheme.accent)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete note?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppTheme.textLight, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textLight)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              notesController.deleteNote(docId);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}