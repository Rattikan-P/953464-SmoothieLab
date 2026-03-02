import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/order_model.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/lab_screen.dart';  

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
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
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
  int _currentIndex = 0;

  // key สำหรับควบคุม LabScreen จากภายนอก
  final GlobalKey<LabScreenState> _labKey = GlobalKey<LabScreenState>();

  void _goToLabWithPreset(List<int> fruitIndexes) {
    setState(() => _currentIndex = 1);
    // รอให้ IndexedStack render ก่อน แล้วค่อย preset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _labKey.currentState?.presetFruits(fruitIndexes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onGoToLabWithPreset: _goToLabWithPreset),
      LabScreen(key: _labKey),
      const OrderHistoryScreen(),
      // const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.science_rounded), label: 'LAB'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'ORDER'),
          // BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'PROFILE'),
        ],
      ),
    );
  }
}