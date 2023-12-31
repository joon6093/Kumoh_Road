import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/announcement_model.dart';
import '../../providers/user_providers.dart';
import '../admin_screens/admin_add_announcement_screan.dart'; // 날짜 형식화를 위한 패키지

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;
  const AnnouncementDetailScreen({Key? key, required this.announcement}) : super(key: key);

  @override
  _AnnouncementDetailScreenState createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  late Announcement currentAnnouncement;

  @override
  void initState() {
    super.initState();
    currentAnnouncement = widget.announcement; // 초기값 설정
    _incrementViews(); // 조회수 증가 함수 호출
  }

  Future<void> _incrementViews() async {
    FirebaseFirestore.instance
        .collection('announcements')
        .doc(widget.announcement.id)
        .update({'views': FieldValue.increment(1)});
  }

  void _editAnnouncement() async {
    final updatedAnnouncement = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => AddAnnouncementScreen(initialAnnouncement: currentAnnouncement),
      ),
    );

    if (updatedAnnouncement != null) {
      setState(() {
        currentAnnouncement = updatedAnnouncement as Announcement; // 상태 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.announcement.date);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
        actions: userProvider.id == 0 ? <Widget>[ // 관리자일 경우 수정 버튼 표시
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAnnouncement,
          ),
        ] : null,
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              '${currentAnnouncement.type} | ${currentAnnouncement.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '관리자 • $formattedDate',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${currentAnnouncement.views+1}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(),
            Text(
              currentAnnouncement.content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
