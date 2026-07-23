import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legend_of_mushroom_bot/providers/game_provider.dart';
import 'package:legend_of_mushroom_bot/providers/analysis_provider.dart';
import 'package:legend_of_mushroom_bot/models/models.dart';

class PvPScreen extends StatefulWidget {
  const PvPScreen({Key? key}) : super(key: key);

  @override
  State<PvPScreen> createState() => _PvPScreenState();
}

class _PvPScreenState extends State<PvPScreen> {
  PvPOpponent? selectedOpponent;
  final List<PvPOpponent> mockOpponents = [
    PvPOpponent(
      id: 'opp_1',
      name: 'Guerreiro Fogo',
      level: 25,
      wins: 45,
      losses: 12,
      petIds: ['pet_fire_1', 'pet_fire_2', 'pet_fire_3'],
      heritageIds: ['her_atk_1', 'her_atk_2'],
      mainElement: 'Fire',
    ),
    PvPOpponent(
      id: 'opp_2',
      name: 'Mago Água',
      level: 28,
      wins: 52,
      losses: 8,
      petIds: ['pet_water_1', 'pet_water_2', 'pet_water_3'],
      heritageIds: ['her_def_1', 'her_def_2'],
      mainElement: 'Water',
    ),
    PvPOpponent(
      id: 'opp_3',
      name: 'Arqueiro Grama',
      level: 26,
      wins: 38,
      losses: 15,
      petIds: ['pet_grass_1', 'pet_grass_2', 'pet_grass_3'],
      heritageIds: ['her_spd_1', 'her_spd_2'],
      mainElement: 'Grass',
    ),
    PvPOpponent(
      id: 'opp_4',
      name: 'Bruxa Elétrica',
      level: 30,
      wins: 60,
      losses: 5,
      petIds: ['pet_elec_1', 'pet_elec_2', 'pet_elec_3'],
      heritageIds: ['her_mixed_1', 'her_mixed_2'],
      mainElement: 'Electric',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise PvP'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer2<GameProvider, AnalysisProvider>(
          builder: (context, gameProvider, analysisProvider, _) {
            return Column(
              children: [
                // Seu Time
                Container(
                  color: Colors.deepOrange.withOpacity(0.1),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu Time',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      gameProvider.playerPets.isEmpty
                          ? Center(
                              child: Text(
                                'Construa seu time na aba anterior',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...gameProvider.playerPets
                                      .map(
                                        (pet) => Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: _getElementColor(
                                                      pet.element),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    pet.element[0],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pet.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Oponentes
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oponentes Disponíveis',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...mockOpponents.map((opponent) {
                          final isSelected =
                              selectedOpponent?.id == opponent.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOpponent = opponent;
                              });
                              // Analisar oponente
                              analysisProvider.analyzePvPOpponent(
                                opponent: opponent,
                                playerLevel: gameProvider.playerLevel,
                                playerPets: gameProvider.playerPets,
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isSelected
                                  ? Colors.deepOrange.withOpacity(0.2)
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.deepOrange,
                                          width: 2,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                opponent.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Level ${opponent.level}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getElementColor(
                                                  opponent.mainElement),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              opponent.mainElement,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildWinRateWidget(
                                            opponent.wins,
                                            opponent.losses,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Duelo com ${opponent.name} iniciado!',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('Desafiar'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                // Análise de Oponente
                if (selectedOpponent != null &&
                    analysisProvider.suggestedCounterBuilds.isNotEmpty)
                  Container(
                    color: Colors.blue.withOpacity(0.05),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Builds Recomendados Contra ${selectedOpponent!.name}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: analysisProvider
                                .suggestedCounterBuilds.length,
                            itemBuilder: (context, index) {
                              final build = analysisProvider
                                  .suggestedCounterBuilds[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildBuildRecommendationCard(
                                  context,
                                  build,
                                  gameProvider,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWinRateWidget(int wins, int losses) {
    final total = wins + losses;
    final winRate = total > 0 ? (wins / total * 100) : 0;
    
    return Column(
      children: [
        Text(
          '${winRate.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          '$wins-$losses',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBuildRecommendationCard(
    BuildContext context,
    Build build,
    GameProvider gameProvider,
  ) {
    return Card(
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  build.name,
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text('${build.efficiency.toStringAsFixed(0)}%'),
                  backgroundColor: Colors.deepOrange.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  gameProvider.applyBuild(build.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Build aplicado!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  'Usar',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case 'Fire':
        return Colors.red;
      case 'Water':
        return Colors.blue;
      case 'Grass':
        return Colors.green;
      case 'Electric':
        return Colors.amber;
      case 'Ice':
        return Colors.cyan;
      case 'Rock':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
