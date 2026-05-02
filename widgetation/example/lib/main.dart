import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  runApp(
    const Widgetation(
      config: WidgetationConfig(name: 'widgetation example', fps: 8),
      child: ExampleApp(),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'widgetation example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  final _items = <String>['Apples', 'Bananas', 'Cherries'];
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('widgetation example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Counter: $_counter', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => setState(() => _counter--),
                          child: const Text('−'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () => setState(() => _counter++),
                          child: const Text('+'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _addItem,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addItem(_controller.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(_items[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _items.removeAt(i)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    setState(() {
      _items.add(t);
      _controller.clear();
    });
  }
}
