import 'package:flutter/material.dart';
import 'user_session.dart';

// ─── COLORS ──────────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF2563EB);
const Color kPrimaryDark = Color(0xFF1D4ED8);
const Color kTextDark    = Color(0xFF1F2937);
const Color kTextLight   = Color(0xFF6B7280);
const Color kWhite       = Color(0xFFFFFFFF);
const Color kLightGray   = Color(0xFFF9FAFB);
const Color kGray        = Color(0xFFE5E7EB);
const Color kSuccess     = Color(0xFF10B981);
const Color kError       = Color(0xFFEF4444);

// ─── PROFILE SCREEN ──────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGray,
      body: CustomScrollView(
        slivers: [

          // ── Expandable Header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: kPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: kWhite, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('My Profile',
              style: TextStyle(color: kWhite, fontWeight: FontWeight.w600, fontSize: 18)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), kPrimary, Color(0xFF3B82F6)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    // Avatar circle with first letter
                    Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          UserSession.name?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: kWhite),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(UserSession.name ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite)),
                    const SizedBox(height: 4),
                    Text('+91 ${UserSession.mobile ?? ''}',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75))),
                  ],
                ),
              ),
            ),
          ),

          // ── Body Content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Account Info
                  _sectionLabel('Account Information'),
                  _card([
                    _infoRow(Icons.person_outline,   'Full Name', UserSession.name ?? ''),
                    _divider(),
                    _infoRow(Icons.phone_outlined,    'Mobile',   '+91 ${UserSession.mobile ?? ''}'),
                    _divider(),
                    _infoRow(Icons.verified_outlined, 'Status',   'Verified ✓', valueColor: kSuccess),
                  ]),

                  const SizedBox(height: 24),

                  // Options
                  _sectionLabel('Options'),
                  _card([
                    _optionRow(context, Icons.history,              'My Applications',  'View your visa applications'),
                    _divider(),
                    _optionRow(context, Icons.notifications_none,   'Notifications',    'Manage your alerts'),
                    _divider(),
                    _optionRow(context, Icons.help_outline,         'Help & Support',   'Get help from our team'),
                    _divider(),
                    _optionRow(context, Icons.info_outline,         'About',            'App version v0.1'),
                  ]),

                  const SizedBox(height: 24),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        UserSession.logout();
                        // Pop all the way back to HomePage
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kError,
                        side: const BorderSide(color: kError, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
        color: kTextLight, letterSpacing: 0.5)),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kGray),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(children: children),
  );

  Widget _divider() => Divider(height: 1, color: kGray, indent: 16, endIndent: 16);

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: kPrimary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: kTextLight)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: valueColor ?? kTextDark)),
      ]),
    );

  Widget _optionRow(BuildContext context, IconData icon, String title, String subtitle) =>
    InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: kPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: kTextLight)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 14, color: kTextLight),
        ]),
      ),
    );
}