import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPage();
}

class _WeatherPage extends State<WeatherPage> {
  final _weatherServices = WeatherServices("420507600c6f4b10290667da69a863c0");
  Weather? _weather;
  bool _isLoading = true;
  String _errorMessage = '';

  // Fetch weather
  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      String cityName = await _weatherServices.getCurrentCity();
      final weatherData = await _weatherServices.getWeather(cityName);
      setState(() {
        _weather = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data. Please try again.';
        _isLoading = false;
      });
      print('Error fetching weather: $e');
    }
  }

  // Animation based on weather condition
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // Background color based on weather condition
  Color getBackgroundColor(String? mainCondition) {
    if (mainCondition == null) return Colors.blueAccent;
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'fog':
        return Colors.grey.shade700;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Colors.indigo.shade900;
      case 'thunderstorm':
        return Colors.deepPurple.shade900;
      case 'clear':
        return Colors.orangeAccent;
      default:
        return Colors.lightBlueAccent;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bgColor = getBackgroundColor(_weather?.mainCondition);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage,
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.045,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size.height * 0.02),
                            ElevatedButton(
                              onPressed: _fetchWeather,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  color: bgColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Refresh button
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: size.width * 0.05, top: size.height * 0.02),
                            child: IconButton(
                              icon: Icon(Icons.refresh,
                                  color: Colors.white, size: size.width * 0.08),
                              onPressed: _fetchWeather,
                            ),
                          ),
                        ),
                        
                        // City name
                        Text(
                          _weather?.cityName ?? 'Unknown Location',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        
                        // Weather animation
                        Lottie.asset(
                          getWeatherAnimation(_weather?.mainCondition),
                          height: size.height * 0.3,
                          width: size.width * 0.8,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: size.height * 0.03),
                        
                        // Temperature
                        Text(
                          '${_weather?.temperature.round() ?? '--'}°C',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        
                        // Weather condition
                        Text(
                          _weather?.mainCondition ?? '--',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}