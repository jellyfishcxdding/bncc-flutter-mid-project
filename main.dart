import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const LondoBellFitnessApp());
}

class LondoBellFitnessApp extends StatelessWidget {
  const LondoBellFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

// Model Data sederhana
class FitnessEntry {
  final DateTime date;
  double value; // Steps (int) atau Water (double)

  FitnessEntry({required this.date, required this.value});
  
  String get dateKey => DateFormat('yyyy-MM-dd').format(date);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Database lokal sementara (In-memory)
  List<FitnessEntry> stepsList = [];
  List<FitnessEntry> waterList = [];

  // Hitung total buat statistik di Home
  int get totalSteps => stepsList.fold(0, (sum, item) => sum + item.value.toInt());
  double get totalWater => waterList.fold(0, (sum, item) => sum + item.value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PT Londo Bell - Fitness Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard("Total Steps", "$totalSteps", Colors.orange),
            const SizedBox(height: 10),
            _buildStatCard("Total Water", "${totalWater.toStringAsFixed(1)} L", Colors.blue),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _navTo(context, StepTrackerScreen(data: stepsList)),
              child: const Text("Manage Steps"),
            ),
            ElevatedButton(
              onPressed: () => _navTo(context, WaterTrackerScreen(data: waterList)),
              child: const Text("Manage Water Intake"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
      child: Column(children: [Text(title), Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
    );
  }

  void _navTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen)).then((_) => setState(() {}));
  }
}

// --- SCREEN STEPS TRACKER ---
class StepTrackerScreen extends StatefulWidget {
  final List<FitnessEntry> data;
  const StepTrackerScreen({super.key, required this.data});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  final TextEditingController _ctrl = TextEditingController();

  void _addOrUpdate(DateTime date, double val) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    // VALIDASI: Cek apa hari ini sudah ada data
    int index = widget.data.indexWhere((e) => e.dateKey == key);

    setState(() {
      if (index != -1) {
        widget.data[index].value = val; // Update kalau sudah ada
      } else {
        widget.data.add(FitnessEntry(date: date, value: val)); // Tambah baru
      }
    });
  }

  String _getParameter(double steps) {
    if (steps < 4000) return "Bad";
    if (steps <= 8000) return "Average";
    return "Good";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Steps Tracker")),
      body: ListView.builder(
        itemCount: widget.data.length,
        itemBuilder: (context, i) {
          final item = widget.data[i];
          return ListTile(
            title: Text("${item.value.toInt()} Steps - ${_getParameter(item.value)}"),
            subtitle: Text(item.dateKey),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => widget.data.removeAt(i))),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInput(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInput(BuildContext context) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Input Steps"),
      content: TextField(controller: _ctrl, keyboardType: TextInputType.number),
      actions: [
        TextButton(onPressed: () {
          _addOrUpdate(DateTime.now(), double.parse(_ctrl.text));
          _ctrl.clear();
          Navigator.pop(context);
        }, child: const Text("Save"))
      ],
    ));
  }
}

// NOTE: WaterTrackerScreen logicnya mirip dengan Steps, tinggal ganti parameter liternya aja.
class WaterTrackerScreen extends StatelessWidget { 
  final List<FitnessEntry> data;
  const WaterTrackerScreen({super.key, required this.data});
  // Implementasi CRUD Water mirip dengan Steps Tracker di atas.
  @override 
  Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Water Intake"))); }
}