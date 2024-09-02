import 'package:floor/floor.dart';
import '../model/Person.dart';

@dao
abstract class PersonDAO {
  @Query('SELECT * FROM Person')
  Stream<List<Person>> getAllPersons();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPerson(Person person);
}
