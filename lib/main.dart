import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legend_of_mushroom_bot/providers/game_provider.dart';
import 'package:legend_of_mushroom_bot/providers/analysis_provider.dart';
import 'package:legend_of_mushroom_bot/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const LegendOfMushroomBot());
}

class LegendOfMushroomBot extends StatelessWidget {
  const LegendOfMushroomBot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'Legend of Mushroom Bot',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
