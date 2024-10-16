import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSVP QR Scanner',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFECF5FF), // Background color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: const Color(0xFF080618), // Navigation bar color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080618),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({Key? key, required this.camera}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Map<String, dynamic>? hrDetails;
  bool rsvpConfirmed = false;
  bool showDetails = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    _startScanningAnimation(); // Start scanning animation here
  }

  Future<void> fetchHRDetails() async {
    // Simulate fetching data with a delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data for demonstration
    setState(() {
      hrDetails = {
        'name': 'John Doe',
        'designation': 'HR Manager',
        'company': 'Tech Corp',
        'sector': 'Technology',
        'email': 'john.doe@example.com',
        'photo': 'assets/pic.png'
      };
      showDetails = true; // Show the HR details card when data is fetched
    });
  }

  void confirmRSVP() {
    setState(() {
      rsvpConfirmed = true; // Confirm the RSVP
    });
  }

  void closeDetails() {
    setState(() {
      showDetails = false; // Close the HR details card
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSVP Scanner'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                _buildScanningOverlay(), // Scanning overlay
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      fetchHRDetails(); // Call the dummy data fetch
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF080618),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan QR',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                if (showDetails && hrDetails != null) ...[
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.3), // Slightly darker shadow
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 5), // Shadow below the card
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  hrDetails![
                                      'photo'], // Use Image.asset for local images
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text("Full Name: ${hrDetails!['name']}",
                                  style: const TextStyle(fontSize: 20)),
                              Text(
                                  "Designation/Role: ${hrDetails!['designation']}",
                                  style: const TextStyle(fontSize: 20)),
                              Text(
                                  "Organization/Company Name: ${hrDetails!['company']}",
                                  style: const TextStyle(fontSize: 20)),
                              Text("Industry Sector: ${hrDetails!['sector']}",
                                  style: const TextStyle(fontSize: 20)),
                              Text("Email Address: ${hrDetails!['email']}",
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 20),
                              SlidingButton(
                                onPressed: confirmRSVP,
                                isConfirmed: rsvpConfirmed,
                              ),
                              if (rsvpConfirmed)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "RSVP done successfully!",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.green),
                                  ),
                                ),
                            ],
                          ),
                          // Improved close button design
                          Positioned(
                            right: 10,
                            top: 10,
                            child: GestureDetector(
                              onTap: closeDetails,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red, // Background color
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.2), // Shadow for the button
                                      blurRadius: 4,
                                      offset:
                                          const Offset(0, 2), // Shadow position
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(
                                    8), // Padding inside the button
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white, // Icon color
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Scanning overlay widget
  Widget _buildScanningOverlay() {
    return Center(
      child: Container(
        width: 250, // Width of the scanning box
        height: 250, // Height of the scanning box
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                height: 2, // Height of the scanning line
                color: Colors.green,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear,
                transform: Matrix4.translationValues(0, _scanningPosition, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _scanningPosition = 0;

  void _startScanningAnimation() {
    // Create a periodic timer to animate the scanning line
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _scanningPosition += 2; // Adjust scanning line's position
        if (_scanningPosition > 250) {
          _scanningPosition = 0; // Reset to top if it goes out of bounds
        }
      });
      _startScanningAnimation(); // Repeat the animation
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SlidingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isConfirmed;

  const SlidingButton({
    Key? key,
    required this.onPressed,
    required this.isConfirmed,
  }) : super(key: key);

  @override
  _SlidingButtonState createState() => _SlidingButtonState();
}

class _SlidingButtonState extends State<SlidingButton> {
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Stack(
        children: [
          // Background track for the slider
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF080618), // Track background color
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          // Sliding button
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (!widget.isConfirmed) {
                  setState(() {
                    _dragPosition = details.localPosition.dx
                        .clamp(0.0, 260.0); // Limit the dragging range
                  });
                }
              },
              onHorizontalDragEnd: (details) {
                if (_dragPosition > 220) {
                  widget.onPressed(); // Trigger RSVP confirmation
                } else {
                  setState(() {
                    _dragPosition =
                        0.0; // Reset the button if not fully dragged
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: widget.isConfirmed
                      ? Colors.green
                      : Colors.white, // Change color on confirmation
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.black),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                widget.isConfirmed ? 'Confirmed' : 'Slide to Confirm',
                style: TextStyle(
                  color: widget.isConfirmed ? Colors.green : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
