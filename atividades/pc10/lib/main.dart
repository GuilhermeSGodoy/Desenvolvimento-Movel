import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/AppDatabase.dart';
import 'view/PersonViewModel.dart';
import 'model/Person.dart';
import 'data/PersonDAO.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database.personDao));
}

class MyApp extends StatelessWidget {
  final PersonDAO _personDao;

  const MyApp(this._personDao, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PersonViewModel(_personDao),
        ),
      ],
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Person List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text;
              final age = int.parse(_ageController.text);
              viewModel.addPerson(name, age);
            },
            child: const Text('Add'),
          ),
          Expanded(
            child: StreamBuilder<List<Person>>(
              stream: viewModel.persons,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final persons = snapshot.data!;
                return ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return ListTile(
                      title: Text(person.name),
                      subtitle: Text('Age: ${person.age}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
