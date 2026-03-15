import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart'; // For navigation link (remove if not needed)
import 'splash_screen.dart';

// ─── COLORS (from CSS variables) ───────────────────────────────────────────
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

void main() {
  runApp(const AnantGlobalApp());
}

class AnantGlobalApp extends StatelessWidget {
  const AnantGlobalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANANT GLOBAL | Your Global Opportunity Starts Here',
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: kWhite,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── HOME PAGE ───────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          // ── Main scrollable content ──
          CustomScrollView(
            slivers: [
              // Sticky Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  menuOpen: _menuOpen,
                  onMenuToggle: () => setState(() => _menuOpen = !_menuOpen),
                  onConsultation: _openModal,
                ),
              ),

              // Mobile menu drawer (below header)
              if (_menuOpen)
                SliverToBoxAdapter(child: _MobileMenu(onConsultation: _openModal)),

              // Hero Section
              SliverToBoxAdapter(child: _HeroSection(onConsultation: _openModal)),

              // Trust / Stats Section
              const SliverToBoxAdapter(child: _TrustSection()),

              // Services Section
              const SliverToBoxAdapter(child: _ServicesSection()),

              // Countries Section
              const SliverToBoxAdapter(child: _CountriesSection()),

              // IELTS Section
              const SliverToBoxAdapter(child: _IeltsSection()),

              // CTA Section
              SliverToBoxAdapter(child: _CtaSection(onConsultation: _openModal)),

              // Footer
              const SliverToBoxAdapter(child: _Footer()),
            ],
          ),

          // ── Consultation Modal Overlay ──
          if (_showConsultationModal)
            _ConsultationModal(onClose: _closeModal),
        ],
      ),
    );
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool menuOpen;
  final VoidCallback onMenuToggle;
  final VoidCallback onConsultation;
  const _HeaderDelegate({required this.menuOpen, required this.onMenuToggle, required this.onConsultation});

  @override double get minExtent => 70;
  @override double get maxExtent => 70;
  @override bool shouldRebuild(_HeaderDelegate old) => old.menuOpen != menuOpen;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isWide = MediaQuery.of(context).size.width > 768;
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo + Brand
          Row(
            children: [
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
                  const Text('ANANT GLOBAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextDark)),
                  Text('Global Opportunities', style: TextStyle(fontSize: 11, color: kTextLight)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Desktop Nav
          if (isWide) ...[
            _navLink('HOME'),
            _navLink('SERVICES'),
            _navLink('COUNTRIES'),
            _navLink('CONTACT'),
            _navLink('AI'),
            _navLink('NEWS'),
            _navLink('IELTS'),
            // _navLink('Login'),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('FREE CONSULTATION', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],

          // Mobile hamburger
          if (!isWide)
            IconButton(
              onPressed: onMenuToggle,
              icon: Icon(menuOpen ? Icons.close : Icons.menu, color: kTextDark),
            ),
        ],
      ),
    );
  }

  Widget _navLink(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextDark, letterSpacing: 0.3)),
    );
  }

}



// ─── MOBILE MENU ─────────────────────────────────────────────────────────────
class _MobileMenu extends StatelessWidget {
  final VoidCallback onConsultation;
  const _MobileMenu({required this.onConsultation});

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
              child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
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

// ─── HERO SECTION ────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VoidCallback onConsultation;
  const _HeroSection({required this.onConsultation});

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
      child: Column(
        children: [
          const Text(
            'Your Global Opportunity\nStarts Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42, fontWeight: FontWeight.w700,
              color: kWhite, height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Expert guidance from start to success. We provide comprehensive\nimmigration and study abroad solutions tailored to your unique goals.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Color(0xFFBFDBFE), height: 1.6),
          ),
          const SizedBox(height: 36),
          ElevatedButton(


            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SignupScreen()),
  );
},


            style: ElevatedButton.styleFrom(
              backgroundColor: kWhite, foregroundColor: kPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Register Now...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── TRUST / STATS SECTION ───────────────────────────────────────────────────
class _TrustSection extends StatelessWidget {
  const _TrustSection();

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
        children: stats.map((s) => _TrustCard(
          icon: s['icon'] as IconData,
          number: s['number'] as String,
          label: s['label'] as String,
        )).toList(),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  const _TrustCard({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: kPrimary, size: 26),
        ),
        const SizedBox(height: 16),
        Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, color: kTextLight)),
      ]),
    );
  }
}

// ─── SERVICES SECTION ────────────────────────────────────────────────────────
class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.airplane_ticket, 'title': 'Tourist Visa',        'desc': 'Tourist visa assistance for travel to all countries worldwide.'},
      {'icon': Icons.school,          'title': 'Study Visa',           'desc': 'Study visa processing, including guidance for admission to top international colleges and universities.'},
      {'icon': Icons.work,            'title': 'Career Counselling',   'desc': 'Personalized career planning and job search strategies for international opportunities.'},
      {'icon': Icons.description,     'title': 'Documentation Help',   'desc': 'Professional assistance with all required documentation, verification, and legal formalities.'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: kWhite,
      child: Column(children: [
        _SectionHeader(title: 'Our Services', subtitle: 'Comprehensive solutions for your global journey'),
        const SizedBox(height: 40),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24, runSpacing: 24,
          children: services.map((s) => _ServiceCard(
            icon: s['icon'] as IconData,
            title: s['title'] as String,
            desc: s['desc'] as String,
          )).toList(),
        ),
      ]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _ServiceCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGray),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: kPrimary, size: 24),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kTextDark)),
        const SizedBox(height: 10),
        Text(desc, style: const TextStyle(fontSize: 14, color: kTextLight, height: 1.5)),
      ]),
    );
  }
}

// ─── COUNTRIES SECTION ───────────────────────────────────────────────────────
class _CountriesSection extends StatelessWidget {
  const _CountriesSection();

  @override
  Widget build(BuildContext context) {
    final countries = ['🇺🇸 USA', '🇨🇦 Canada', '🇬🇧 UK', '🇦🇺 Australia', '🇪🇺 Europe'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: kLightGray,
      child: Column(children: [
        _SectionHeader(title: 'Top Destinations', subtitle: 'Explore opportunities in popular countries around the world'),
        const SizedBox(height: 40),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20, runSpacing: 20,
          children: countries.map((c) {
            final parts = c.split(' ');
            final flag = parts[0];
            final name = parts.sublist(1).join(' ');
            return _CountryCard(flag: flag, name: name);
          }).toList(),
        ),
      ]),
    );
  }
}

class _CountryCard extends StatelessWidget {
  final String flag;
  final String name;
  const _CountryCard({required this.flag, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Text(flag, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
      ]),
    );
  }
}

// ─── IELTS SECTION ───────────────────────────────────────────────────────────
class _IeltsSection extends StatelessWidget {
  const _IeltsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: kWhite,
      child: Column(children: [
        _SectionHeader(title: 'IELTS Excellence Program', subtitle: 'Master English proficiency with our comprehensive IELTS preparation'),
        const SizedBox(height: 40),

        // Banner
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Column(children: [
                Text('8.5+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kWhite)),
                Text('Average Score', style: TextStyle(fontSize: 12, color: kWhite)),
              ]),
            ),
            const SizedBox(width: 24),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Achieve Your Dream IELTS Score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite)),
              SizedBox(height: 8),
              Text(
                'Join thousands of students who have successfully cleared IELTS with our expert guidance, personalized coaching, and proven strategies.',
                style: TextStyle(fontSize: 14, color: Color(0xFFBFDBFE), height: 1.5),
              ),
            ])),
          ]),
        ),

        const SizedBox(height: 40),

        // Features
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20, runSpacing: 20,
          children: const [
            _IeltsFeature(icon: Icons.trending_up,   title: 'Personalized Coaching',    desc: 'One-on-one sessions with certified IELTS trainers tailored to your needs.'),
            _IeltsFeature(icon: Icons.menu_book,     title: 'Comprehensive Material',   desc: 'Access to updated study materials, practice tests, and IELTS resources.'),
            _IeltsFeature(icon: Icons.access_time,   title: 'Flexible Schedules',       desc: 'Choose from weekday, weekend, or intensive crash courses.'),
            _IeltsFeature(icon: Icons.laptop,        title: 'Online & Offline',         desc: 'Learn from anywhere with our hybrid learning model.'),
          ],
        ),

        const SizedBox(height: 40),

        // Score Bars
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kLightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Target Score Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextDark)),
            const SizedBox(height: 24),
            _ScoreBar(label: 'Listening', score: '8.0+', percent: 0.85, color: kPrimary),
            _ScoreBar(label: 'Reading',   score: '7.5+', percent: 0.80, color: const Color(0xFF10B981)),
            _ScoreBar(label: 'Writing',   score: '7.0+', percent: 0.75, color: const Color(0xFFF59E0B)),
            _ScoreBar(label: 'Speaking',  score: '8.0+', percent: 0.85, color: const Color(0xFF8B5CF6)),
          ]),
        ),

        const SizedBox(height: 40),

        // Packages
        const Text('Choose Your IELTS Package', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: kTextDark)),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20, runSpacing: 20,
          children: const [
            _IeltsPackage(title: '1-Month',             price: '14,999', isPopular: false, features: ['Live Classes', 'Study Material', '4 Mock Tests', 'Expert Support']),
            _IeltsPackage(title: '3-Month',             price: '24,999', isPopular: true,  features: ['Live Classes & Online', 'Personal Mentor', '15 Mock Tests', 'Writing Evaluation', 'Speaking Practice', 'Priority Support']),
            _IeltsPackage(title: 'IELTS Exam Included', price: '39,999', isPopular: false, features: ['IELTS Study + Exam Fee', '1-on-1 Coaching', 'Valid on Study Visa', 'Test Day Simulation', 'Score Guarantee*', '24/7 Support']),
          ],
        ),
      ]),
    );
  }
}

class _IeltsFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _IeltsFeature({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGray),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kPrimary, size: 22),
        ),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(fontSize: 13, color: kTextLight, height: 1.5)),
      ]),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final String score;
  final double percent;
  final Color color;
  const _ScoreBar({required this.label, required this.score, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 14, color: kTextDark, fontWeight: FontWeight.w500)),
          Text(score, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: kGray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ]),
    );
  }
}

class _IeltsPackage extends StatelessWidget {
  final String title;
  final String price;
  final bool isPopular;
  final List<String> features;
  const _IeltsPackage({required this.title, required this.price, required this.isPopular, required this.features});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 240,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isPopular ? kPrimary : kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPopular ? kPrimary : kGray, width: 2),
            boxShadow: isPopular ? [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (isPopular) const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isPopular ? kWhite : kTextDark)),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('₹', style: TextStyle(fontSize: 16, color: isPopular ? kWhite : kPrimary, fontWeight: FontWeight.w600)),
              Text(price, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: isPopular ? kWhite : kTextDark)),
            ]),
            const SizedBox(height: 20),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Icon(Icons.check_circle, size: 16, color: isPopular ? kWhite : kPrimary),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: TextStyle(fontSize: 13, color: isPopular ? kWhite.withOpacity(0.9) : kTextLight))),
              ]),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? kWhite : kPrimary,
                  foregroundColor: isPopular ? kPrimary : kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Enroll Now', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
        if (isPopular)
          Positioned(
            top: -12, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(20)),
                child: const Text('Most Popular', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kWhite)),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── CTA SECTION ─────────────────────────────────────────────────────────────
class _CtaSection extends StatelessWidget {
  final VoidCallback onConsultation;
  const _CtaSection({required this.onConsultation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
      ),
      child: Column(children: [
        const Text('Start Your Global Journey Today', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: kWhite)),
        const SizedBox(height: 16),
        const Text(
          'Take the first step towards your international dreams. Our expert consultants\nare ready to guide you through every step of the process.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFFBFDBFE), height: 1.6),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onConsultation,
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhite, foregroundColor: kPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Book Free Consultation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ─── FOOTER ──────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: kDarkBg,
      child: Column(children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 40, runSpacing: 40,
          children: [
            // Brand info
            SizedBox(width: 280, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ANANT GLOBAL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite)),
              const SizedBox(height: 12),
              Text('Your trusted partner for immigration and study abroad solutions.', style: TextStyle(fontSize: 14, color: kTextLighter, height: 1.6)),
              const SizedBox(height: 16),
              _footerContact(Icons.email,       'info@anantglobal.in'),
              _footerContact(Icons.phone,       '+91 9015220818'),
              _footerContact(Icons.location_on, 'Hamirpur, Himachal Pradesh, India'),
            ])),

            // Quick links
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Quick Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kWhite)),
              const SizedBox(height: 16),
              ...['Home', 'Services', 'Countries', 'Contact'].map((l) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(l, style: TextStyle(fontSize: 14, color: kTextLighter)),
                )
              ),
            ]),

            // Social
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Connect With Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kWhite)),
              const SizedBox(height: 16),
              Row(children: [
                _socialIcon(Icons.facebook),
                _socialIcon(Icons.camera_alt),
                _socialIcon(Icons.link),
                _socialIcon(Icons.message),
              ]),
              const SizedBox(height: 20),
              Text('© 2025 ANANT GLOBAL. All rights reserved.', style: TextStyle(fontSize: 13, color: kTextLighter)),
            ]),
          ],
        ),
        const SizedBox(height: 30),
        Divider(color: kDarkCard),
        const SizedBox(height: 16),
        Text('anantglobal-version v.0.1', style: TextStyle(fontSize: 13, color: kTextLighter)),
      ]),
    );
  }

  Widget _footerContact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 14, color: kTextLighter),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: kTextLighter)),
      ]),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 38, height: 38,
      decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: kWhite),
    );
  }
}

// ─── CONSULTATION MODAL ──────────────────────────────────────────────────────
class _ConsultationModal extends StatefulWidget {
  final VoidCallback onClose;
  const _ConsultationModal({required this.onClose});

  @override
  State<_ConsultationModal> createState() => _ConsultationModalState();
}

class _ConsultationModalState extends State<_ConsultationModal> {
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _emailController   = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedSubject;
  bool _submitted = false;

  final _subjects = ['Study Abroad', 'Visa Guidance', 'Immigration', 'IELTS Preparation', 'Career Counseling', 'Other'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 500,
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                    ),
                    child: Row(children: [
                      const Expanded(child: Text('Book Free Consultation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kWhite))),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: const Icon(Icons.close, color: kWhite, size: 24),
                      ),
                    ]),
                  ),

                  // Modal Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: _submitted ? _successView() : _formView(),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Fill the form below and our expert will contact you within 24 hours',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: kTextLight)),
      const SizedBox(height: 20),
      _formField('Full Name *', _nameController, 'Enter your full name'),
      _formField('Phone Number *', _phoneController, 'Enter your phone number', keyboardType: TextInputType.phone),
      _formField('Email Address *', _emailController, 'Enter your email address', keyboardType: TextInputType.emailAddress),

      // Subject dropdown
      const Text('Subject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(border: Border.all(color: kGray, width: 2), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSubject,
            hint: const Text('Select your interest', style: TextStyle(color: kTextLighter)),
            isExpanded: true,
            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _selectedSubject = v),
          ),
        ),
      ),
      const SizedBox(height: 16),

      _formField('Message (Optional)', _messageController, 'Tell us about your requirements...', maxLines: 3),

      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => setState(() => _submitted = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary, foregroundColor: kWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.send, size: 18),
          ]),
        ),
      ),
      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 12),
      Row(children: const [Icon(Icons.shield, size: 16, color: kPrimary), SizedBox(width: 8), Text('Your information is 100% secure', style: TextStyle(fontSize: 13, color: kTextLight))]),
      const SizedBox(height: 8),
      Row(children: const [Icon(Icons.access_time, size: 16, color: kPrimary), SizedBox(width: 8), Text('Response within 24 hours', style: TextStyle(fontSize: 13, color: kTextLight))]),
    ]);
  }

  Widget _formField(String label, TextEditingController controller, String hint, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kTextLighter),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGray, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGray, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ]),
    );
  }

  Widget _successView() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 30),
      const Icon(Icons.check_circle, size: 72, color: Color(0xFF10B981)),
      const SizedBox(height: 20),
      const Text('Thank You!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kTextDark)),
      const SizedBox(height: 12),
      const Text(
        'Your consultation request has been submitted successfully. Our expert will contact you within 24 hours.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: kTextLight, height: 1.6),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: widget.onClose,
        style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: kWhite, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

// ─── REUSABLE SECTION HEADER ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kTextDark)),
      const SizedBox(height: 12),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: kTextLight, height: 1.5)),
    ]);
  }
}

