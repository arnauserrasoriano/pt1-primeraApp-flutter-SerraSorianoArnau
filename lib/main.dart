import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var generatedWords =
      <
        WordPair
      >[]; //Creem una nova llista per guardar els WordPair generats. Aquesta llista s'inicialitza com a buida.
  var current =
      WordPair.random(); //Creem una variable current que conté un WordPair aleatori. Aquesta variable s'inicialitza amb un WordPair aleatori generat per la funció random() de la classe WordPair.

  void getNext() {
    generatedWords.insert(
      0,
      current,
    ); //Afegim el nou WordPair generat a la llista generatedWords.

    current =
        WordPair.random(); //Generem un nou WordPair aleatori i l'assignem a la variable current.

    notifyListeners(); //Notifiquem als widgets que escolten aquest ChangeNotifier que hi ha hagut un canvi en l'estat. Això farà que els widgets es tornin a construir amb el nou estat.
  }

  // ↓ Add the code below.
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ...

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 450;
        final pageContent = Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        );

        return Scaffold(
          body: isCompact
              ? pageContent
              : Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        extended: constraints.maxWidth >= 600,
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.favorite),
                            label: Text('Favorites'),
                          ),
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                        },
                      ),
                    ),
                    Expanded(child: pageContent),
                  ],
                ),
          bottomNavigationBar: isCompact
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite),
                      label: 'Favorites',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

// ...
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Column(
      //Creem un widget Column que conté una llista de widgets. Aquesta llista conté un ListView que mostra els WordPair generats, un BigCard que mostra el WordPair actual, i dos botons per afegir o eliminar el WordPair actual dels favorits i per generar un nou WordPair.
      children: [
        Expanded(
          child: ListView(
            children: [
              for (var pair
                  in appState
                      .generatedWords) //Per cada WordPair generat, creem un ListTile amb el text del WordPair en minúscules i centrat.
                ListTile(
                  title: Text(
                    pair.asLowerCase,
                    textAlign: TextAlign.center,
                  ), //Per cada WordPair generat, creem un ListTile amb el text del WordPair en minúscules i centrat.
                  trailing: Icon(
                    appState.favorites.contains(pair)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
            ],
          ),
        ),
        Center(
          child: BigCard(pair: pair),
        ), //Creem un widget Center que conté un BigCard que mostra el WordPair actual. El BigCard és un widget personalitzat que mostra el WordPair en un estil més gran i amb un fons de color.

        SizedBox(height: 10),

        Row(
          //Creem un widget Row que conté una llista de widgets. Aquesta llista conté dos botons per afegir o eliminar el WordPair actual dels favorits i per generar un nou WordPair.
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                appState.toggleFavorite();
              },
              icon: Icon(icon),
              label: Text('Like'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Next'),
            ),
          ],
        ),

        SizedBox(height: 20),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ↓ Add this.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        // ↓ Change this line.
        child: Text(pair.asLowerCase, style: style),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${appState.favorites.length} favorites:',
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            title: Text(pair.asLowerCase),
            trailing: IconButton(
              icon: Icon(Icons.favorite),
              tooltip: 'Remove from favorites',
              onPressed: () => appState.removeFavorite(pair),
            ),
          ),
      ],
    );
  }
}
