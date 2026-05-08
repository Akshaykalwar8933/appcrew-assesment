import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/network_service.dart';

class NotesController extends GetxController {
  static NotesController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final searchController = TextEditingController();

  // Master list — always holds ALL notes from Firestore
  final RxList<Map<String, dynamic>> _allNotes = <Map<String, dynamic>>[].obs;

  // Filtered list — what the UI actually renders
  final RxList<Map<String, dynamic>> filteredNotes = <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;
  RxBool isSearchActive = false.obs;

  // Stream states for UI
  RxBool isFirstLoad = true.obs;
  RxBool hasFirestoreError = false.obs;

  StreamSubscription<QuerySnapshot>? _notesSub;

  String get uid => FirebaseAuth.instance.currentUser!.uid;
  bool get isSearching => searchController.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _subscribeToNotes();
    // Listen to search field — filter locally, no Firestore call
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
    _notesSub?.cancel();
    super.onClose();
  }

  // ── Firestore real-time listener ─────────────────────────────────────────────

  void _subscribeToNotes() {
    _notesSub = _firestore
        .collection('notes')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
        isFirstLoad.value = false;
        hasFirestoreError.value = false;

        // Sort newest first in Dart — no composite index needed
        final docs = snapshot.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .toList()
          ..sort((a, b) {
            final aTime =
                (a['created_at'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['created_at'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

        _allNotes.value = docs;

        // Re-apply whatever search is currently active
        _applyFilter();
      },
      onError: (_) {
        isFirstLoad.value = false;
        hasFirestoreError.value = true;
      },
    );
  }

  // ── Refresh (pull-to-refresh) ─────────────────────────────────────────────────

  Future<void> refreshNotes() async {
    // Cancel existing subscription and re-subscribe — forces a fresh fetch
    await _notesSub?.cancel();
    isFirstLoad.value = true;
    hasFirestoreError.value = false;
    _subscribeToNotes();
    // Wait briefly so the spinner shows and the new snapshot arrives
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // ── Search ───────────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    isSearchActive.value = searchController.text.trim().isNotEmpty;
    _applyFilter(); // purely local — zero network calls
  }

  void _applyFilter() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      // No search → show everything
      filteredNotes.value = List.from(_allNotes);
      return;
    }

    filteredNotes.value = _allNotes.where((note) {
      final title = (note['title'] as String? ?? '').toLowerCase();
      // final content = (note['content'] as String? ?? '').toLowerCase();
      return title.contains(query) ;
          // || content.contains(query);
    }).toList();
  }

  void clearSearch() {
    searchController.clear();
    // _onSearchChanged fires automatically via listener
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  void prepareForAdd() {
    titleController.clear();
    contentController.clear();
  }

  void prepareForEdit(String title, String content) {
    titleController.text = title;
    contentController.text = content;
  }

  Future<void> addNote() async {
    if (!_validate()) return;
    if (!ConnectivityService.instance.checkAndAlert()) return;
    try {
      isLoading.value = true;
      final docRef = _firestore.collection('notes').doc();
      await docRef.set({
        'id': docRef.id,
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'user_id': uid,
        'created_at': Timestamp.fromDate(DateTime.now()),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
      titleController.clear();
      contentController.clear();
      Get.back();
      _showSuccess('Note added successfully!');
    } catch (e) {
      _showError('Could not save note. Check your connection and try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNote(String docId) async {
    if (!_validate()) return;
    if (!ConnectivityService.instance.checkAndAlert()) return;
    try {
      isLoading.value = true;
      await _firestore.collection('notes').doc(docId).update({
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
      Get.back();
      _showSuccess('Note updated!');
    } catch (e) {
      _showError('Could not update note. Check your connection and try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(String docId) async {
    if (!ConnectivityService.instance.checkAndAlert()) return;
    try {
      await _firestore.collection('notes').doc(docId).delete();
      _showSuccess('Note deleted.');
    } catch (e) {
      _showError('Could not delete note. Check your connection and try again.');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  bool _validate() {
    if (titleController.text.trim().isEmpty) {
      _showError('Please enter a title.');
      return false;
    }
    if (contentController.text.trim().isEmpty) {
      _showError('Please enter some content.');
      return false;
    }
    return true;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Done',
      message,
      backgroundColor: const Color(0xFF1A1A2E),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFE94560),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}