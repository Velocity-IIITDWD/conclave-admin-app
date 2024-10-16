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
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF080618),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
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
        'photo': 'https://via.placeholder.com/150'
      };
    });
  }

  void confirmRSVP() {
    setState(() {
      rsvpConfirmed = true; // Confirm the RSVP
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSVP QR Code Scanner'),
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
                      'Get HR Details',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                if (hrDetails != null) ...[
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: Image.network(
                              hrDetails!['photo'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("Full Name: ${hrDetails!['name']}",
                              style: const TextStyle(fontSize: 20)),
                          Text("Designation/Role: ${hrDetails!['designation']}",
                              style: const TextStyle(fontSize: 20)),
                          Text("Organization/Company Name: ${hrDetails!['company']}",
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
                                style: const TextStyle(fontSize: 18, color: Colors.green),
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
            return Center(child: CircularProgressIndicator());
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

class SlidingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isConfirmed;

  const SlidingButton({Key? key, required this.onPressed, required this.isConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ElevatedButton(
        onPressed: isConfirmed ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF080618),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Slide to Confirm RSVP',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
