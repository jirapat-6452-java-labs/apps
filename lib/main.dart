import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:apps/datbase.dart';

void main() {
 runApp(
  MaterialApp(
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(),
      ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: const FoodRandomizerApp(),
    ),
  );
}

class FoodRandomizerApp extends StatefulWidget {
  const FoodRandomizerApp({super.key});

  @override
  _FoodRandomizerAppState createState() => _FoodRandomizerAppState();
}

class _FoodRandomizerAppState extends State<FoodRandomizerApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool started = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  void navigateToFoodRandomizerScreen() {
  startApp();
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, FadeTransition, SlideTransition) {
        return FoodRandomizerScreen(onBack: () {});
      },
      transitionsBuilder: (context, FadeTransition, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = FadeTransition.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ),
  );
}

  void startApp() {
    setState(() {
      started = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return started
        ? FoodRandomizerScreen(onBack: () {})
        : _buildStartScreen();
  }

  Widget _buildStartScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to Dice & Dine',
          style: GoogleFonts.abel(fontWeight:FontWeight.w700)
        ),
        backgroundColor: Colors.red[600],
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            ClipPath(
              clipper: UpperHalfClipper(),
              child: Container(
                color: Colors.red[600],
              ),
            ),
            CustomPaint(
              painter: WavyLinePainter(),
              child: Container(),
            ),
            Center(
              child: ElevatedButton(
                onPressed: navigateToFoodRandomizerScreen,
                child: Text('Start', style: GoogleFonts.abel(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Custom Clipper for upper half
class UpperHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height / 2)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height / 2)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Painter for wavy line
class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(
          size.width / 4, size.height / 2 - 20, size.width / 2, size.height / 2)
      ..quadraticBezierTo(3 * size.width / 4, size.height / 2 + 20, size.width,
          size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FoodRandomizerScreen extends StatefulWidget {
  final VoidCallback onBack;
  const FoodRandomizerScreen({super.key, required this.onBack});

  @override
  _FoodRandomizerScreenState createState() => _FoodRandomizerScreenState();
}

class _FoodRandomizerScreenState extends State<FoodRandomizerScreen> {
  final List<Food> allFoods = myallFoods;
  List<Food> selectedFoods = [];
  int totalCalories = 0;

  Set<Food> selectedSet = {};  // A set to keep track of selected food items

void randomizeFood() {
  final Random random = Random();

  // Clear the selected set when re-randomizing foods
  selectedSet.clear();
  selectedFoods.clear();
  totalCalories = 0;

  // Select new random foods until we have 3 unique ones or all available food items are exhausted
  while (selectedSet.length < 3 && selectedSet.length < allFoods.length) {
    final int randomNumber = random.nextInt(allFoods.length);
    final Food selectedFood = allFoods[randomNumber];

    if (!selectedSet.contains(selectedFood)) {
      selectedSet.add(selectedFood);
      selectedFoods.add(selectedFood);
      totalCalories += selectedFood.calories;
    }
  }

  setState(() {});
}

void resetFoods() {
  selectedFoods.clear();
  totalCalories = 0;
  // Clear the selected set when resetting foods
  selectedSet.clear();
  setState(() {});
}

  void backToStart() {
    widget.onBack();
  }

bool isCalculatorOpen = false;

void toggleCalculator() {
  setState(() {
    isCalculatorOpen = !isCalculatorOpen;
  });
}

void openCalculator() {
  if (isCalculatorOpen) {
    // Show the calorie calculator
    String selectedExercise = 'Running'; // Default exercise
    String selectedGender = 'Male'; // Default gender

    void calculateBurnTime() {
      // Constants for calories burned per hour for different exercises and genders
      const Map<String, double> caloriesPerHourMale = {
        'Running': 600,
        'Walking': 300,
        'Aerobic Dancing': 400,
        'Swimming': 700,
      };
      const Map<String, double> caloriesPerHourFemale = {
        'Running': 500,
        'Walking': 250,
        'Aerobic Dancing': 350,
        'Swimming': 600,
      };

      // Get the calories burned per hour based on selected exercise and gender
      double caloriesPerHour = 0;
      if (selectedGender == 'Male') {
        caloriesPerHour = caloriesPerHourMale[selectedExercise] ?? 0;
      } else {
        caloriesPerHour = caloriesPerHourFemale[selectedExercise] ?? 0;
      }

      // Calculate the time required to burn the calories
      double timeInHours = totalCalories / caloriesPerHour;

      // Display the result to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Estimated Time to Burn Calories'),
            content: Text('Based on your selection, it will take approximately ${timeInHours.toStringAsFixed(2)} hours to burn ${totalCalories.toString()} calories.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Calorie Calculator'),
                backgroundColor: Colors.red[900],
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      toggleCalculator(); // Close the calculator
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Option to select exercise type
                  ListTile(
                    title: Text('Select Exercise Type'),
                    trailing: DropdownButton<String>(
                      value: selectedExercise,
                      onChanged: (String? value) {
                        setState(() {
                          selectedExercise = value!;
                        });
                      },
                      items: <String>['Running', 'Walking', 'Aerobic Dancing', 'Swimming']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  // Option to select gender
                  ListTile(
                    title: Text('Select Gender'),
                    trailing: DropdownButton<String>(
                      value: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                      items: <String>['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  // Button to calculate burn time
                  ElevatedButton(
                    onPressed: calculateBurnTime,
                    child: Text('Let\'s calculate the burn!'),
                  ),
                  // Add any additional widgets or customization here
                ],
              ),
            );
          },
        );
      },
    );
  } else {
    // Show the food selection list
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Food Selection'),
                backgroundColor: Colors.red[900],
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      toggleCalculator(); // Close the food selection list
                    },
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: selectedFoods.length,
                itemBuilder: (BuildContext context, int index) {
                  final food = selectedFoods[index];
                  final bool isSelected = selectedSet.contains(food);

                  return CheckboxListTile(
                    title: Text('${food.name} - ${food.calories} Calories'),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          selectedSet.add(food); // Add the food to the selected set
                        } else {
                          selectedSet.remove(food); // Remove the food from the selected set
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice & Dine', style: GoogleFonts.abel(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.red[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: backToStart,
          ),
        ],
      ),
      body: Container(
        color: Colors.red[600],
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selectedFoods.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedFoods.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Food Details',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${selectedFoods[index].name}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Calories: ${selectedFoods[index].calories}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Did you know? : ${selectedFoods[index].detail}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.center,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      selectedFoods[index].image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8), // Add spacing between image and text
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Text(
                                    '${selectedFoods[index].name} - ${selectedFoods[index].calories} Calories',
                                    style: GoogleFonts.abel(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 20),
                  if (totalCalories > 0)
                    Text(
                      'Total Calories: $totalCalories',
                      style: GoogleFonts.abel(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: randomizeFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: Text('Dice & Dine', style: GoogleFonts.abel(fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: resetFoods,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: Text('Reset Food', style: GoogleFonts.abel(fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: 70), // Add spacing
                ],
              ),
            ),
          Positioned(
            bottom: 10,
            right: 10, // Adjust the position based on your UI
            child: ElevatedButton(
              onPressed: toggleCalculator,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Mode: ${isCalculatorOpen ? 'Calculator' : 'Food Selection'}',
                style: GoogleFonts.abel(fontWeight: FontWeight.w700, color: Colors.red.shade700)
              ),
            ),
          ),
            Positioned(
              bottom: 58,
              right: 20,
              child: GestureDetector(
                onTap: openCalculator,
                child: Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow, // or any color you prefer
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/burger.png", // Replace with your image asset
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 57, // Adjust this value to position the text properly
                      left: 0, // Adjust this value to align the text horizontally
                      right: 0, // Adjust this value to align the text horizontally
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2), // Adjust padding as needed
                        decoration: BoxDecoration(
                          color: Color.fromARGB(136, 255, 255, 255),
                          borderRadius: BorderRadius.circular(8), // Adjust border radius as needed
                        ),
                        child: const Text(
                          'Click here!',
                          textAlign: TextAlign.center, // Center the text horizontally
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
      ),
    );
  }
}