import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legend_of_mushroom_bot/providers/game_provider.dart';
import 'package:legend_of_mushroom_bot/providers/analysis_provider.dart';
import 'package:legend_of_mushroom_bot/widgets/phase_card.dart';

class PhaseAnalyzerScreen extends StatefulWidget {
  const PhaseAnalyzerScreen({Key? key}) : super(key: key);

  @override
  State<PhaseAnalyzerScreen> createState() => _PhaseAnalyzerScreenState();
}

class _PhaseAnalyzerScreenState extends State<PhaseAnalyzerScreen> {
  int selectedPhase = 1;
  bool showRecommendation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisador de Fases'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer2<GameProvider, AnalysisProvider>(
          builder: (context, gameProvider, analysisProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de Fase
                  Text(
                    'Selecione a Fase',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<int>(
                      value: selectedPhase,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: List.generate(
                        100,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Fase ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPhase = value;
                            showRecommendation = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Analisar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analisar Fase'),
                      onPressed: () async {
                        await analysisProvider.analyzePhase(
                          phaseNumber: selectedPhase,
                          playerLevel: gameProvider.playerLevel,
                          playerAttack: gameProvider.calculateTotalAttack(),
                          playerDefense: gameProvider.calculateTotalDefense(),
                          playerSpeed: gameProvider.calculateTotalSpeed(),
                          playerPets: gameProvider.playerPets,
                          playerHeritages: gameProvider.playerHeritages,
                        );
                        setState(() {
                          showRecommendation = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Informações do Jogador
                  _buildPlayerStats(context, gameProvider),
                  const SizedBox(height: 24),

                  // Recomendação
                  if (analysisProvider.isAnalyzing)
                    const Center(child: CircularProgressIndicator())
                  else if (showRecommendation &&
                      analysisProvider.currentRecommendation != null)
                    _buildRecommendation(
                      context,
                      analysisProvider.currentRecommendation!,
                    )
                  else if (analysisProvider.error != null)
                    _buildErrorWidget(context, analysisProvider.error!)
                  else
                    Center(
                      child: Text(
                        'Selecione uma fase e clique em Analisar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerStats(BuildContext context, GameProvider gameProvider) {
    return Card(
      elevation: 0,
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seus Stats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem('Level', gameProvider.playerLevel.toString()),
                _statItem('ATK', gameProvider.calculateTotalAttack().toString()),
                _statItem('DEF', gameProvider.calculateTotalDefense().toString()),
                _statItem('SPD', gameProvider.calculateTotalSpeed().toString()),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: gameProvider.calculateEfficiency() / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Eficiência: ${gameProvider.calculateEfficiency().toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildRecommendation(
    BuildContext context,
    Recommendation recommendation,
  ) {
    final isHighPriority = recommendation.priority == 'HIGH';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isHighPriority
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            border: Border(
              left: BorderSide(
                color: isHighPriority ? Colors.red : Colors.green,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isHighPriority ? Icons.warning : Icons.info,
                    color: isHighPriority ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isHighPriority ? Colors.red : Colors.green,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendation.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ação Recomendada:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.action,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: recommendation.expectedDifficultyReduction / 100,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text(
                'Redução de Dificuldade: ${recommendation.expectedDifficultyReduction}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Build Recomendado',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildBuildCard(context, recommendation.suggestedBuild),
      ],
    );
  }

  Widget _buildBuildCard(BuildContext context, Build build) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              build.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              build.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text('Eficiência: ${build.efficiency.toStringAsFixed(1)}%'),
                  backgroundColor: Colors.deepOrange.withOpacity(0.2),
                ),
                Chip(
                  label: Text('Level ${build.minLevel}+'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<GameProvider>().applyBuild(build.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Build aplicado com sucesso!')),
                );
              },
              child: const Text('Aplicar Build'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
