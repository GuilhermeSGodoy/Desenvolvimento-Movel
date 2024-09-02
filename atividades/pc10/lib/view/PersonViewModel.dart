import 'package:flutter/material.dart';
import '../model/Person.dart';
import '../data/PersonDAO.dart';

class PersonViewModel extends ChangeNotifier {
  final PersonDAO _personDao;

  PersonViewModel(this._personDao);

  Stream<List<Person>> get persons => _personDao.getAllPersons();

  Future<void> addPerson(String name, int age) async {
    final newPerson = Person(DateTime.now().millisecondsSinceEpoch, name, age);
    await _personDao.insertPerson(newPerson);
    notifyListeners();
  }
}
