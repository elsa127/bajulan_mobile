import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bajulan_mobile/app/shared/colors.dart';
import 'package:bajulan_mobile/app/shared/widgets/bottom_nav.dart'; // Import navbar baru

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

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
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildBentoGrid(),
            const SizedBox(height: 32),
            _buildOngoingEvent(),
            const SizedBox(height: 32),
            _buildRecentBookings(),
            const SizedBox(height: 100), // Beri ruang agar tidak tertutup Navbar
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-package'), // Pastikan route ini sudah terdaftar
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // MEMANGGIL NAVBAR YANG SUDAH DIPISAH
      bottomNavigationBar: CustomBottomNav(),
    );
  }

  // --- WIDGET HELPER (APPBAR, WELCOME, DLL) ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFDFBF7),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
          ),
          const SizedBox(width: 12),
          Text(
            'Bajulan Admin',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
      shape: const Border(bottom: BorderSide(color: Color(0xFFE8E2D0), width: 1)),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dina iki, 12 Oktober',
          style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          'Sugeng Rawuh, Admin',
          style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBentoGrid() {
    return Column(
      children: [
        _buildNeumorphicCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total transactions today', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('128', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text('+12% from yesterday', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 32),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconBox(Icons.payments, AppColors.secondary.withOpacity(0.2), AppColors.secondary),
                    const SizedBox(height: 12),
                    const Text('Total revenue', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Rp 4.2M', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconBox(Icons.event_available, AppColors.tertiary.withOpacity(0.1), AppColors.tertiary),
                    const SizedBox(height: 12),
                    const Text('New bookings', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('24', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOngoingEvent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ongoing Events', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('View all', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1533900298318-6b8da08a523e?q=80&w=1000'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.primary.withOpacity(0.8)]),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.tertiary, borderRadius: BorderRadius.circular(6)),
                      child: const Text('LIVE NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Bersih Desa Festival', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Punden Bajulan • 450 Attendees', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Bookings', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildBookingItem(Icons.eco, 'Agro-Tourism Pack', 'Budi Santoso • 2h ago', 'CONFIRMED', Colors.green),
        const SizedBox(height: 12),
        _buildBookingItem(Icons.temple_buddhist, 'Cultural Heritage Tour', 'Siti Aminah • 4h ago', 'PENDING', Colors.orange),
      ],
    );
  }

  Widget _buildNeumorphicCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2D4236).withOpacity(0.08), blurRadius: 12, offset: const Offset(6, 6)),
          const BoxShadow(color: Colors.white, blurRadius: 12, offset: Offset(-6, -6)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIconBox(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: iconColor),
    );
  }

  Widget _buildBookingItem(IconData icon, String title, String subtitle, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}