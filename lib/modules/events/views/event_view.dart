import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bajulan_mobile/app/shared/colors.dart';
import 'package:bajulan_mobile/app/shared/widgets/bottom_nav.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildSearchAndFilter(),
            const SizedBox(height: 24),
            _buildEventList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFDFBF7),
      elevation: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
          ),
          const SizedBox(width: 12),
          Text('Bajulan Admin',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
        ),
      ],
      shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0))),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, // Ubah ke center agar lebih simetris
      children: [
        // 1. Tambahkan Expanded di sini agar teks mengalah pada tombol
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cultural Events',
                style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Manage Bajulan\'s festivities',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 2. Gunakan Flexible agar tombol menyesuaikan lebar tersisa
        Flexible(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.8, // Sedikit diperlebar agar tidak sesak
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard('Active', '12', AppColors.primary),
        _buildStatCard('Upcoming', '05', AppColors.secondary),
        _buildStatCard('Attendees', '1.2k', AppColors.primary),
        _buildStatCard('Capacity', '88%', const Color(0xFF364B3F)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(4, 4)),
          const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-4, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 2)
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(4, 4))],
          ),
          child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
        )
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildEventCard(
          'Bersih Desa Slametan',
          'Aug 15, 2024',
          'Balai Adat Bajulan',
          'Ritual',
          'Confirmed',
          AppColors.primary,
          'https://placehold.co/200x200/2D4236/white.png?text=Ritual',
        ),
        const SizedBox(height: 16),
        _buildEventCard(
          'Malam Gamelan',
          'Sept 02, 2024',
          'Pendopo Timur',
          'Musical',
          'Draft',
          Colors.grey,
          'https://placehold.co/200x200/8C6A43/white.png?text=Gamelan',
        ),
      ],
    );
  }

  Widget _buildEventCard(String title, String date, String loc, String tag, String status, Color statusColor, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(8, 8)),
          const BoxShadow(color: Colors.white, blurRadius: 15, offset: Offset(-8, -8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imgUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 70, height: 70, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(width: 16),
          // 3. Expanded di sini sangat penting agar teks tidak mendorong keluar layar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(tag, style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    // Wrap dengan Flexible agar teks tanggal tidak overflow
                    Flexible(child: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAvatarStack(),
                    Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 50,
      height: 20,
      child: Stack(
        children: [
          const Positioned(left: 0, child: CircleAvatar(radius: 9, backgroundColor: Colors.grey)),
          const Positioned(left: 10, child: CircleAvatar(radius: 9, backgroundColor: Colors.blueGrey)),
          Positioned(
            left: 20,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: AppColors.secondary,
              child: const Text('+45', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}