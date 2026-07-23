import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legend_of_mushroom_bot/providers/game_provider.dart';

class TeamBuilderScreen extends StatefulWidget {
  const TeamBuilderScreen({Key? key}) : super(key: key);

  @override
  State<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  String selectedTab = 'pets'; // pets, heritages, skills

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construtor de Time'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, _) {
            return Column(
              children: [
                // Tabs
                Container(
                  color: Colors.grey.withOpacity(0.1),
                  child: Row(
                    children: [
                      _buildTab(
                        'Pets',
                        selectedTab == 'pets',
                        () => setState(() => selectedTab = 'pets'),
                      ),
                      _buildTab(
                        'Heranças',
                        selectedTab == 'heritages',
                        () => setState(() => selectedTab = 'heritages'),
                      ),
                      _buildTab(
                        'Skills',
                        selectedTab == 'skills',
                        () => setState(() => selectedTab = 'skills'),
                      ),
                    ],
                  ),
                ),
                // Conteúdo
                Expanded(
                  child: selectedTab == 'pets'
                      ? _buildPetsTab(context, gameProvider)
                      : selectedTab == 'heritages'
                          ? _buildHeritagesTab(context, gameProvider)
                          : _buildSkillsTab(context, gameProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.deepOrange : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.deepOrange : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetsTab(BuildContext context, GameProvider gameProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Time Atual
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu Time (${gameProvider.playerPets.length}/3)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                gameProvider.playerPets.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Nenhum pet selecionado',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameProvider.playerPets.length,
                        itemBuilder: (context, index) {
                          final pet = gameProvider.playerPets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getElementColor(pet.element),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    pet.element[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(pet.name),
                              subtitle: Text(
                                '${pet.rarity} • ATK: ${pet.attack} DEF: ${pet.defense}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  gameProvider.removePetFromTeam(pet.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          const Divider(),
          // Disponíveis
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pets Disponíveis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                gameProvider.petsCache.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameProvider.petsCache.length,
                        itemBuilder: (context, index) {
                          final pet = gameProvider.petsCache[index];
                          final isSelected = gameProvider.playerPets
                              .any((p) => p.id == pet.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected
                                ? Colors.deepOrange.withOpacity(0.2)
                                : null,
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getElementColor(pet.element),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    pet.element[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(pet.name),
                              subtitle: Text(
                                '${pet.rarity} • Nível ${pet.level}',
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.deepOrange,
                                    )
                                  : null,
                              onTap: gameProvider.playerPets.length < 3 &&
                                      !isSelected
                                  ? () {
                                      gameProvider.addPetToTeam(pet.id);
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeritagesTab(
      BuildContext context, GameProvider gameProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Heranças Selecionadas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suas Heranças (${gameProvider.playerHeritages.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                gameProvider.playerHeritages.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Nenhuma herança selecionada',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameProvider.playerHeritages.length,
                        itemBuilder: (context, index) {
                          final heritage = gameProvider.playerHeritages[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(heritage.type),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              title: Text(heritage.name),
                              subtitle: Text(
                                '${heritage.type} +${heritage.bonus}%',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  gameProvider
                                      .removeHeritageFromTeam(heritage.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          const Divider(),
          // Heranças Disponíveis
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heranças Disponíveis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                gameProvider.heritagesCache.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameProvider.heritagesCache.length,
                        itemBuilder: (context, index) {
                          final heritage = gameProvider.heritagesCache[index];
                          final isSelected = gameProvider.playerHeritages
                              .any((h) => h.id == heritage.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected
                                ? Colors.blue.withOpacity(0.2)
                                : null,
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(heritage.type),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              title: Text(heritage.name),
                              subtitle: Text(
                                '${heritage.rarity} • ${heritage.type}',
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                    )
                                  : null,
                              onTap: !isSelected
                                  ? () {
                                      gameProvider
                                          .addHeritageToTeam(heritage.id);
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(BuildContext context, GameProvider gameProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Skills Selecionadas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suas Skills (${gameProvider.playerSkills.length}/4)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                gameProvider.playerSkills.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Nenhuma skill selecionada',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameProvider.playerSkills.length,
                        itemBuilder: (context, index) {
                          final skill = gameProvider.playerSkills[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getSkillTypeColor(skill.type),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              title: Text(skill.name),
                              subtitle: Text(
                                'Cooldown: ${skill.cooldown}s • Mana: ${skill.manaCost}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  gameProvider.removeSkillFromTeam(skill.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          const Divider(),
          // Skills Disponíveis
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills Disponíveis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                gameProvider.skillsCache.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameProvider.skillsCache.length,
                        itemBuilder: (context, index) {
                          final skill = gameProvider.skillsCache[index];
                          final isSelected = gameProvider.playerSkills
                              .any((s) => s.id == skill.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected
                                ? Colors.purple.withOpacity(0.2)
                                : null,
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getSkillTypeColor(skill.type),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              title: Text(skill.name),
                              subtitle: Text(
                                '${skill.type} • Dano: ${skill.damage}',
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.purple,
                                    )
                                  : null,
                              onTap: gameProvider.playerSkills.length < 4 &&
                                      !isSelected
                                  ? () {
                                      gameProvider.addSkillToTeam(skill.id);
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ATK':
        return Colors.red;
      case 'DEF':
        return Colors.blue;
      case 'SPD':
        return Colors.yellow;
      case 'HP':
        return Colors.green;
      case 'MIXED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getSkillTypeColor(String type) {
    switch (type) {
      case 'ATK':
        return Colors.red;
      case 'DEF':
        return Colors.blue;
      case 'HEAL':
        return Colors.green;
      case 'BUFF':
        return Colors.purple;
      case 'DEBUFF':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
