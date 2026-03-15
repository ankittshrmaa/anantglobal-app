import 'package:flutter/material.dart';
import 'user_session.dart';
import 'profile_screen.dart';

// ─── COLORS ──────────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF2563EB);
const Color kPrimaryDark = Color(0xFF1D4ED8);
const Color kTextDark    = Color(0xFF1F2937);
const Color kTextLight   = Color(0xFF6B7280);
const Color kTextLighter = Color(0xFF9CA3AF);
const Color kWhite       = Color(0xFFFFFFFF);
const Color kLightGray   = Color(0xFFF9FAFB);
const Color kGray        = Color(0xFFE5E7EB);
const Color kDarkBg      = Color(0xFF111827);
const Color kDarkCard    = Color(0xFF1F2937);

// ─── HOME PAGE 2 (Logged In version) ─────────────────────────────────────────
class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});
  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  bool _menuOpen = false;
  bool _showConsultationModal = false;

  void _openModal()  => setState(() => _showConsultationModal = true);
  void _closeModal() => setState(() => _showConsultationModal = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header with profile avatar
              SliverPersistentHeader(
                pinned: true,
                delegate: _Header2Delegate(
                  menuOpen: _menuOpen,
                  onMenuToggle: () => setState(() => _menuOpen = !_menuOpen),
                  onConsultation: _openModal,
                  onProfileTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                    // Refresh state after returning from profile (e.g. logout)
                    if (!UserSession.isLoggedIn && mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      setState(() {});
                    }
                  },
                ),
              ),

              if (_menuOpen)
                SliverToBoxAdapter(child: _MobileMenu2(onConsultation: _openModal)),

              // Hero — logged in version
              SliverToBoxAdapter(child: _HeroSection2(onConsultation: _openModal)),

              const SliverToBoxAdapter(child: _TrustSection2()),
              const SliverToBoxAdapter(child: _ServicesSection2()),
              const SliverToBoxAdapter(child: _CountriesSection2()),
              const SliverToBoxAdapter(child: _IeltsSection2()),
              SliverToBoxAdapter(child: _CtaSection2(onConsultation: _openModal)),
              const SliverToBoxAdapter(child: _Footer2()),
            ],
          ),

          if (_showConsultationModal)
            _ConsultationModal2(onClose: _closeModal),
        ],
      ),
    );
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────
class _Header2Delegate extends SliverPersistentHeaderDelegate {
  final bool menuOpen;
  final VoidCallback onMenuToggle;
  final VoidCallback onConsultation;
  final VoidCallback onProfileTap;

  const _Header2Delegate({
    required this.menuOpen,
    required this.onMenuToggle,
    required this.onConsultation,
    required this.onProfileTap,
  });

  @override double get minExtent => 70;
  @override double get maxExtent => 70;
  @override bool shouldRebuild(_Header2Delegate old) => old.menuOpen != menuOpen;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isWide = MediaQuery.of(context).size.width > 768;
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo + Brand
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.language, color: kWhite, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ANANT GLOBAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextDark)),
                Text('Global Opportunities',
                  style: TextStyle(fontSize: 11, color: kTextLight)),
              ],
            ),
          ]),

          const Spacer(),

          // Desktop nav
          if (isWide) ...[
            _navLink('HOME'),
            _navLink('SERVICES'),
            _navLink('COUNTRIES'),
            _navLink('CONTACT'),
            _navLink('AI'),
            _navLink('NEWS'),
            _navLink('IELTS'),
            const SizedBox(width: 20),

            // Profile avatar with first letter of name
            GestureDetector(
              onTap: onProfileTap,
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      UserSession.name?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: kWhite, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  UserSession.name ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextDark),
                ),
              ]),
            ),
          ],

          // Mobile hamburger
          if (!isWide)
            Row(children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      UserSession.name?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(color: kWhite, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onMenuToggle,
                icon: Icon(menuOpen ? Icons.close : Icons.menu, color: kTextDark),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _navLink(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextDark, letterSpacing: 0.3)),
  );
}

// ─── MOBILE MENU ─────────────────────────────────────────────────────────────
class _MobileMenu2 extends StatelessWidget {
  final VoidCallback onConsultation;
  const _MobileMenu2({required this.onConsultation});

  @override
  Widget build(BuildContext context) {
    final items = ['HOME', 'SERVICES', 'COUNTRIES', 'CONTACT', 'AI', 'NEWS', 'IELTS'];
    return Container(
      color: kWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...items.map((item) => Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kGray))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(item,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: onConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('FREE CONSULTATION', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HERO SECTION (logged in) ─────────────────────────────────────────────────
class _HeroSection2 extends StatelessWidget {
  final VoidCallback onConsultation;
  const _HeroSection2({required this.onConsultation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
      ),
      child: Column(children: [
        // Welcome message for logged in user
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.waving_hand, color: kWhite, size: 16),
            const SizedBox(width: 8),
            Text(
              'Welcome back, ${UserSession.name?.split(' ')[0] ?? ''}!',
              style: const TextStyle(fontSize: 13, color: kWhite, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your Global Opportunity\nStarts Here',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: kWhite, height: 1.3),
        ),
        const SizedBox(height: 20),
        const Text(
          'Expert guidance from start to success. We provide comprehensive\nimmigration and study abroad solutions tailored to your unique goals.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: Color(0xFFBFDBFE), height: 1.6),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: onConsultation,
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhite, foregroundColor: kPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Book Free Consultation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ─── TRUST SECTION ───────────────────────────────────────────────────────────
class _TrustSection2 extends StatelessWidget {
  const _TrustSection2();
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.calendar_today, 'number': '3+ Years', 'label': 'Experience'},
      {'icon': Icons.flag,           'number': '98%',       'label': 'Success Rate'},
      {'icon': Icons.language,       'number': '6+',        'label': 'Countries Covered'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: kLightGray,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 24, runSpacing: 24,
        children: stats.map((s) => _TrustCard2(
          icon: s['icon'] as IconData,
          number: s['number'] as String,
          label: s['label'] as String,
        )).toList(),
      ),
    );
  }
}

class _TrustCard2 extends StatelessWidget {
  final IconData icon; final String number; final String label;
  const _TrustCard2({required this.icon, required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        Container(width: 56, height: 56,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: kPrimary, size: 26)),
        const SizedBox(height: 16),
        Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, color: kTextLight)),
      ]),
    );
  }
}

// ─── SERVICES SECTION ────────────────────────────────────────────────────────
class _ServicesSection2 extends StatelessWidget {
  const _ServicesSection2();
  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.airplane_ticket, 'title': 'Tourist Visa',      'desc': 'Tourist visa assistance for travel to all countries worldwide.'},
      {'icon': Icons.school,          'title': 'Study Visa',         'desc': 'Study visa processing, including guidance for admission to top international colleges and universities.'},
      {'icon': Icons.work,            'title': 'Career Counselling', 'desc': 'Personalized career planning and job search strategies for international opportunities.'},
      {'icon': Icons.description,     'title': 'Documentation Help', 'desc': 'Professional assistance with all required documentation, verification, and legal formalities.'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: kWhite,
      child: Column(children: [
        _SectionHeader2(title: 'Our Services', subtitle: 'Comprehensive solutions for your global journey'),
        const SizedBox(height: 40),
        Wrap(alignment: WrapAlignment.center, spacing: 24, runSpacing: 24,
          children: services.map((s) => _ServiceCard2(
            icon: s['icon'] as IconData, title: s['title'] as String, desc: s['desc'] as String,
          )).toList()),
      ]),
    );
  }
}

class _ServiceCard2 extends StatelessWidget {
  final IconData icon; final String title; final String desc;
  const _ServiceCard2({required this.icon, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGray),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: kPrimary, size: 24)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kTextDark)),
        const SizedBox(height: 10),
        Text(desc, style: const TextStyle(fontSize: 14, color: kTextLight, height: 1.5)),
      ]),
    );
  }
}

// ─── COUNTRIES SECTION ───────────────────────────────────────────────────────
class _CountriesSection2 extends StatelessWidget {
  const _CountriesSection2();
  @override
  Widget build(BuildContext context) {
    final countries = ['🇺🇸 USA', '🇨🇦 Canada', '🇬🇧 UK', '🇦🇺 Australia', '🇪🇺 Europe'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: kLightGray,
      child: Column(children: [
        _SectionHeader2(title: 'Top Destinations', subtitle: 'Explore opportunities in popular countries around the world'),
        const SizedBox(height: 40),
        Wrap(alignment: WrapAlignment.center, spacing: 20, runSpacing: 20,
          children: countries.map((c) {
            final parts = c.split(' ');
            return _CountryCard2(flag: parts[0], name: parts.sublist(1).join(' '));
          }).toList()),
      ]),
    );
  }
}

class _CountryCard2 extends StatelessWidget {
  final String flag; final String name;
  const _CountryCard2({required this.flag, required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        Text(flag, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
      ]),
    );
  }
}

// ─── IELTS SECTION ───────────────────────────────────────────────────────────
class _IeltsSection2 extends StatelessWidget {
  const _IeltsSection2();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: kWhite,
      child: Column(children: [
        _SectionHeader2(title: 'IELTS Excellence Program', subtitle: 'Master English proficiency with our comprehensive IELTS preparation'),
        const SizedBox(height: 40),
        Container(
          width: double.infinity, constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Column(children: [
                Text('8.5+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kWhite)),
                Text('Average Score', style: TextStyle(fontSize: 12, color: kWhite)),
              ])),
            const SizedBox(width: 24),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Achieve Your Dream IELTS Score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite)),
              SizedBox(height: 8),
              Text('Join thousands of students who have successfully cleared IELTS with our expert guidance.',
                style: TextStyle(fontSize: 14, color: Color(0xFFBFDBFE), height: 1.5)),
            ])),
          ]),
        ),
        const SizedBox(height: 40),
        Wrap(alignment: WrapAlignment.center, spacing: 20, runSpacing: 20, children: const [
          _IeltsFeature2(icon: Icons.trending_up,  title: 'Personalized Coaching',  desc: 'One-on-one sessions with certified IELTS trainers.'),
          _IeltsFeature2(icon: Icons.menu_book,    title: 'Comprehensive Material', desc: 'Updated study materials and practice tests.'),
          _IeltsFeature2(icon: Icons.access_time,  title: 'Flexible Schedules',     desc: 'Weekday, weekend, or intensive crash courses.'),
          _IeltsFeature2(icon: Icons.laptop,       title: 'Online & Offline',       desc: 'Hybrid learning model — attend anywhere.'),
        ]),
        const SizedBox(height: 40),
        Wrap(alignment: WrapAlignment.center, spacing: 20, runSpacing: 20, children: const [
          _IeltsPackage2(title: '1-Month',             price: '14,999', isPopular: false, features: ['Live Classes', 'Study Material', '4 Mock Tests', 'Expert Support']),
          _IeltsPackage2(title: '3-Month',             price: '24,999', isPopular: true,  features: ['Live Classes & Online', 'Personal Mentor', '15 Mock Tests', 'Writing Evaluation', 'Speaking Practice', 'Priority Support']),
          _IeltsPackage2(title: 'IELTS Exam Included', price: '39,999', isPopular: false, features: ['IELTS Study + Exam Fee', '1-on-1 Coaching', 'Valid on Study Visa', 'Score Guarantee*', '24/7 Support']),
        ]),
      ]),
    );
  }
}

class _IeltsFeature2 extends StatelessWidget {
  final IconData icon; final String title; final String desc;
  const _IeltsFeature2({required this.icon, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Container(width: 220, padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kLightGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: kGray)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kPrimary, size: 22)),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(fontSize: 13, color: kTextLight, height: 1.5)),
      ]));
  }
}

class _IeltsPackage2 extends StatelessWidget {
  final String title; final String price; final bool isPopular; final List<String> features;
  const _IeltsPackage2({required this.title, required this.price, required this.isPopular, required this.features});
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(width: 240, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isPopular ? kPrimary : kWhite, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPopular ? kPrimary : kGray, width: 2),
          boxShadow: isPopular ? [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : []),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (isPopular) const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isPopular ? kWhite : kTextDark)),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('₹', style: TextStyle(fontSize: 16, color: isPopular ? kWhite : kPrimary, fontWeight: FontWeight.w600)),
            Text(price, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: isPopular ? kWhite : kTextDark)),
          ]),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Icon(Icons.check_circle, size: 16, color: isPopular ? kWhite : kPrimary),
              const SizedBox(width: 8),
              Expanded(child: Text(f, style: TextStyle(fontSize: 13, color: isPopular ? kWhite.withOpacity(0.9) : kTextLight))),
            ]))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? kWhite : kPrimary, foregroundColor: isPopular ? kPrimary : kWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
              child: const Text('Enroll Now', style: TextStyle(fontWeight: FontWeight.w600)))),
        ])),
      if (isPopular)
        Positioned(top: -12, left: 0, right: 0,
          child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(20)),
            child: const Text('Most Popular', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kWhite))))),
    ]);
  }
}

// ─── CTA SECTION ─────────────────────────────────────────────────────────────
class _CtaSection2 extends StatelessWidget {
  final VoidCallback onConsultation;
  const _CtaSection2({required this.onConsultation});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimary, kPrimaryDark])),
      child: Column(children: [
        const Text('Start Your Global Journey Today', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: kWhite)),
        const SizedBox(height: 16),
        const Text('Take the first step towards your international dreams.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFFBFDBFE), height: 1.6)),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: onConsultation,
          style: ElevatedButton.styleFrom(backgroundColor: kWhite, foregroundColor: kPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
          child: const Text('Book Free Consultation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ─── FOOTER ──────────────────────────────────────────────────────────────────
class _Footer2 extends StatelessWidget {
  const _Footer2();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: kDarkBg,
      child: Column(children: [
        Wrap(alignment: WrapAlignment.spaceBetween, spacing: 40, runSpacing: 40, children: [
          SizedBox(width: 280, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ANANT GLOBAL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite)),
            const SizedBox(height: 12),
            Text('Your trusted partner for immigration and study abroad solutions.',
              style: TextStyle(fontSize: 14, color: kTextLighter, height: 1.6)),
            const SizedBox(height: 16),
            _fc(Icons.email,       'info@anantglobal.in'),
            _fc(Icons.phone,       '+91 9015220818'),
            _fc(Icons.location_on, 'Hamirpur, Himachal Pradesh, India'),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Quick Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kWhite)),
            const SizedBox(height: 16),
            ...['Home', 'Services', 'Countries', 'Contact'].map((l) =>
              Padding(padding: const EdgeInsets.only(bottom: 10),
                child: Text(l, style: TextStyle(fontSize: 14, color: kTextLighter)))),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Connect With Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kWhite)),
            const SizedBox(height: 16),
            Row(children: [
              _si(Icons.facebook), _si(Icons.camera_alt), _si(Icons.link), _si(Icons.message),
            ]),
            const SizedBox(height: 20),
            Text('© 2025 ANANT GLOBAL. All rights reserved.',
              style: TextStyle(fontSize: 13, color: kTextLighter)),
          ]),
        ]),
        const SizedBox(height: 30),
        Divider(color: kDarkCard),
        const SizedBox(height: 16),
        Text('anantglobal-version v.0.1', style: TextStyle(fontSize: 13, color: kTextLighter)),
      ]),
    );
  }
  Widget _fc(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 14, color: kTextLighter), const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13, color: kTextLighter)),
    ]));
  Widget _si(IconData icon) => Container(
    margin: const EdgeInsets.only(right: 10), width: 38, height: 38,
    decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(8)),
    child: Icon(icon, size: 18, color: kWhite));
}

// ─── CONSULTATION MODAL ──────────────────────────────────────────────────────
class _ConsultationModal2 extends StatefulWidget {
  final VoidCallback onClose;
  const _ConsultationModal2({required this.onClose});
  @override
  State<_ConsultationModal2> createState() => _ConsultationModal2State();
}

class _ConsultationModal2State extends State<_ConsultationModal2> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _msgCtrl     = TextEditingController();
  String? _subject;
  bool _submitted    = false;
  final _subjects    = ['Study Abroad', 'Visa Guidance', 'Immigration', 'IELTS Preparation', 'Career Counseling', 'Other'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 500, margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimary, kPrimaryDark])),
                  child: Row(children: [
                    const Expanded(child: Text('Book Free Consultation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kWhite))),
                    GestureDetector(onTap: widget.onClose,
                      child: const Icon(Icons.close, color: kWhite, size: 24)),
                  ])),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: _submitted ? _success() : _form())),
              ]),
            ),
          ),
        )),
      ),
    );
  }

  Widget _form() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Fill the form and our expert will contact you within 24 hours',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: kTextLight)),
    const SizedBox(height: 20),
    _field('Full Name *', _nameCtrl, 'Enter your full name'),
    _field('Phone Number *', _phoneCtrl, 'Enter your phone number', keyboardType: TextInputType.phone),
    _field('Email Address *', _emailCtrl, 'Enter your email address', keyboardType: TextInputType.emailAddress),
    const Text('Subject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(border: Border.all(color: kGray, width: 2), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: _subject,
        hint: const Text('Select your interest', style: TextStyle(color: kTextLighter)),
        isExpanded: true,
        items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (v) => setState(() => _subject = v)))),
    const SizedBox(height: 16),
    _field('Message (Optional)', _msgCtrl, 'Tell us about your requirements...', maxLines: 3),
    const SizedBox(height: 8),
    SizedBox(width: double.infinity,
      child: ElevatedButton(
        onPressed: () => setState(() => _submitted = true),
        style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: kWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(width: 8), Icon(Icons.send, size: 18),
        ]))),
  ]);

  Widget _field(String label, TextEditingController ctrl, String hint, {TextInputType? keyboardType, int maxLines = 1}) =>
    Padding(padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
        const SizedBox(height: 8),
        TextField(controller: ctrl, keyboardType: keyboardType, maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: kTextLighter),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGray, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGray, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
      ]));

  Widget _success() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const SizedBox(height: 30),
    const Icon(Icons.check_circle, size: 72, color: Color(0xFF10B981)),
    const SizedBox(height: 20),
    const Text('Thank You!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kTextDark)),
    const SizedBox(height: 12),
    const Text('Your consultation request has been submitted. We will contact you within 24 hours.',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: kTextLight, height: 1.6)),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: widget.onClose,
      style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600))),
  ]);
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────
class _SectionHeader2 extends StatelessWidget {
  final String title; final String subtitle;
  const _SectionHeader2({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kTextDark)),
    const SizedBox(height: 12),
    Text(subtitle, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, color: kTextLight, height: 1.5)),
  ]);
}