import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legend_of_mushroom_bot/providers/game_provider.dart';

class BuildsScreen extends StatefulWidget {
  const BuildsScreen({Key? key}) : super(key: key);

  @override
  State<BuildsScreen> createState() => _BuildsScreenState();
}

class _BuildsScreenState extends State<BuildsScreen> {
  String filterType = 'all'; // all, PvE, PvP, Support, Damage
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builds'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, _) {
            final allBuilds = gameProvider.buildsCache;
            
            // Aplicar filtros
            var filteredBuilds = allBuilds.where((build) {
              final matchesType = filterType == 'all' || build.type == filterType;
              final matchesSearch =
                  build.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  build.description
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
              final matchesLevel = build.minLevel <= gameProvider.playerLevel;
              return matchesType && matchesSearch && matchesLevel;
            }).toList();

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar builds...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('PvE', 'PvE'),
                        const SizedBox(width: 8),
                        _buildFilterChip('PvP', 'PvP'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Suporte', 'Support'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Dano', 'Damage'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Builds List
                Expanded(
                  child: filteredBuilds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum build encontrado',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredBuilds.length,
                          itemBuilder: (context, index) {
                            final build = filteredBuilds[index];
                            return _buildBuildCard(context, build, gameProvider);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isActive = filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (selected) {
        setState(() {
          filterType = value;
        });
      },
      backgroundColor:
          isActive ? Colors.deepOrange.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
      side: BorderSide(
        color: isActive ? Colors.deepOrange : Colors.transparent,
      ),
    );
  }

  Widget _buildBuildCard(
    BuildContext context,
    Build build,
    GameProvider gameProvider,
  ) {
    final isApplied = gameProvider.playerPets.map((p) => p.id).toList() ==
        build.petIds;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    build.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    build.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Chip(
                label: Text(build.type),
                backgroundColor: _getTypeColor(build.type).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _getTypeColor(build.type),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${build.efficiency.toStringAsFixed(1)}%'),
                backgroundColor: Colors.deepOrange.withOpacity(0.2),
                labelStyle: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 12,
                ),
              ),
              if (isApplied)
                const SizedBox(width: 8),
              if (isApplied)
                Chip(
                  label: const Text('Aplicado'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                  avatar: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBuildSection(
                  context,
                  'Descrição',
                  build.description,
                ),
                const SizedBox(height: 16),
                _buildBuildSection(
                  context,
                  'Estratégia',
                  build.strategy,
                ),
                const SizedBox(height: 16),
                Text(
                  'Requisitos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Level ${build.minLevel}+',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${build.petIds.length} Pets',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${build.skillIds.length} Skills',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await gameProvider.applyBuild(build.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Build aplicado com sucesso!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        setState(() {});
                      }
                    },
                    child: const Text('Aplicar Build'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildSection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'PvE':
        return Colors.green;
      case 'PvP':
        return Colors.red;
      case 'Support':
        return Colors.blue;
      case 'Damage':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
