import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/order_model.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/home_screen.dart';
import 'screens/lab_screen.dart';
import 'screens/order_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(OrderModelAdapter());
  await Hive.openBox<OrderModel>('orders');
  runApp(const SmoothieLabApp());
}

class SmoothieLabApp extends StatelessWidget {
  const SmoothieLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'SmoothieLab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
          textTheme: GoogleFonts.notoSansThaiTextTheme(),
          useMaterial3: true,
        ),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<LabScreenState> _labKey = GlobalKey<LabScreenState>();

  @override
  void initState() {
    super.initState();
    // ฟัง NavigationProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().addListener(_onNavChanged);
    });
  }

  void _onNavChanged() {
    final nav = context.read<NavigationProvider>();
    final fruits = nav.pendingFruits;
    final extras = nav.pendingExtras ?? [];
    final veggies = nav.pendingVeggies ?? [];
    final herbs = nav.pendingHerbs ?? [];
    final toppings = nav.pendingToppings ?? [];
    final menuName = nav.pendingMenuName;
    final menuEmoji = nav.pendingMenuEmoji;
    final size = nav.pendingSize ?? 'S';
    final sweetness = nav.pendingSweetness ?? 'หวานปกติ';

    if (fruits != null) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _labKey.currentState?.presetFruits(
          fruits,
          extrasIndexes: extras,
          veggieIndexes: veggies,
          herbsIndexes: herbs,
          toppingsIndexes: toppings,
          menuName: menuName,
          menuEmoji: menuEmoji,
          size: size,
          sweetness: sweetness,
        );
        nav.clearPendingPreset();
      });
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    context.read<NavigationProvider>().removeListener(_onNavChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = context.watch<NavigationProvider>().currentIndex;

    final List<Widget> screens = [
      const HomeScreen(),
      LabScreen(key: _labKey),
      const OrderHistoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: navIndex, children: screens),
      // floatingActionButton: navIndex == 1 ? null : const FloatingCartButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (i) {
          context.read<NavigationProvider>().goToTab(i);
          // Clear editing index when switching tabs
          context.read<NavigationProvider>().clearEditingIndex();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_rounded),
            label: 'LAB',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'ORDER',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'PROFILE'),
        ],
      ),
    );
  }
}
