import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyCGHLVpDXNKIs16xaetKOurt0vUqplmuJ4',
          appId: '1:400309373110:android:8e1ee98e4414200385be17',
          messagingSenderId: '400309373110',
          projectId: 'smart-home-224ab',
          databaseURL: "https://smart-home-224ab-default-rtdb.firebaseio.com"));
  runApp(const WaterLevelApp());
}

class WaterLevelApp extends StatelessWidget {
  const WaterLevelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Level Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WaterLevelHomePage(),
    );
  }
}

class WaterLevelHomePage extends StatefulWidget {
  const WaterLevelHomePage({Key? key}) : super(key: key);

  @override
  _WaterLevelHomePageState createState() => _WaterLevelHomePageState();
}

class _WaterLevelHomePageState extends State<WaterLevelHomePage> {
  DatabaseReference? _waterLevelRef;
  DatabaseReference? _weeklyUsageRef;
  DatabaseReference? _monthlyUsageRef;
  double waterLevel = 0; // Initial water level percentage

  // Initializing lists to store data fetched from Firebase
  List<double> weeklyUsage = [];
  List<double> monthlyUsage = [];

  @override
  void initState() {
    super.initState();
    listenToWaterLevel();
    fetchUsageData();
  }

  void listenToWaterLevel() {
    _waterLevelRef = FirebaseDatabase.instance.ref().child('percentage');
    _waterLevelRef!.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final value = event.snapshot.value;
        try {
          setState(() {
            waterLevel = double.parse(value.toString());
          });
        } catch (e) {
          print('Error parsing water level: $e');
        }
      }
    });
  }

  void fetchUsageData() {
    _weeklyUsageRef = FirebaseDatabase.instance.ref().child('weekly_usage');
    _monthlyUsageRef = FirebaseDatabase.instance.ref().child('monthly_usage');

    // Fetching weekly usage data
    _weeklyUsageRef!.onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final dynamic values = event.snapshot.value;
          if (values is List) {
            setState(() {
              weeklyUsage = values.map<double>((e) => e.toDouble()).toList();
            });
          } else {
            print('Invalid weekly usage data format');
          }
        } catch (e) {
          print('Error parsing weekly usage data: $e');
        }
      } else {
        print('Weekly usage data snapshot is null');
      }
    });

    // Fetching monthly usage data
    _monthlyUsageRef!.onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final dynamic values = event.snapshot.value;
          if (values is List) {
            setState(() {
              monthlyUsage = values.map<double>((e) => e.toDouble()).toList();
            });
          } else {
            print('Invalid monthly usage data format');
          }
        } catch (e) {
          print('Error parsing monthly usage data: $e');
        }
      } else {
        print('Monthly usage data snapshot is null');
      }
    });
  }

  void storeWeeklyUsageData(List<double> data) {
    _weeklyUsageRef!
        .set(data.asMap().map((key, value) => MapEntry(key.toString(), value)));
  }

  void storeMonthlyUsageData(List<double> data) {
    _monthlyUsageRef!
        .set(data.asMap().map((key, value) => MapEntry(key.toString(), value)));
  }

  String getWaterLevelReport() {
    if (waterLevel >= 80) {
      return 'Water level is high';
    } else if (waterLevel >= 50) {
      return 'Water level is moderate';
    } else if (waterLevel >= 20) {
      return 'Water level is low';
    } else {
      return 'Water level is very low';
    }
  }

  String getSummaryReport() {
    if (waterLevel >= 80) {
      return 'The tank is almost full.';
    } else if (waterLevel >= 50) {
      return 'The tank is about half full.';
    } else if (waterLevel >= 20) {
      return 'The tank is running low.';
    } else {
      return 'The tank is almost empty.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Water Level Monitor'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.water_damage), text: 'Current'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Weekly Report'),
              Tab(icon: Icon(Icons.show_chart), text: 'Monthly Report'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Handle the navigation
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Handle the navigation
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildCurrentWaterLevelView(),
            buildWeeklyReportView(),
            buildMonthlyReportView(),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentWaterLevelView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Current Water Level:',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 100,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 100,
                height: 3 * waterLevel,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${waterLevel.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Text(
            getWaterLevelReport(),
            style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          Text(
            getSummaryReport(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildWeeklyReportView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            'Weekly Water Usage Report',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: weeklyUsage
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(toY: entry.value, color: Colors.blue)
                        ],
                      ),
                    )
                    .toList(),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Mon';
                            break;
                          case 1:
                            text = 'Tue';
                            break;
                          case 2:
                            text = 'Wed';
                            break;
                          case 3:
                            text = 'Thu';
                            break;
                          case 4:
                            text = 'Fri';
                            break;
                          case 5:
                            text = 'Sat';
                            break;
                          case 6:
                            text = 'Sun';
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMonthlyReportView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            'Monthly Water Usage Report',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: monthlyUsage
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(toY: entry.value, color: Colors.blue)
                        ],
                      ),
                    )
                    .toList(),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text((value.toInt() + 1).toString(),
                              style: style),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
