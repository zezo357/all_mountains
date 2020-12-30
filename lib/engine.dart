
import 'package:all_mountains/data.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

class Mountains {
  String name = "";
  String country = "";
  String height = "";
  String photo = "";


  int Selected = 0;
  int Favorite=0;


  Mountains(this.name, this.country, this.height, this.photo, this.Favorite);

  void toggleSelected() {
    Selected++;
    Selected = Selected % 2;
    print(Selected);
  }
  void toggleFavorite() {
    Favorite++;
    Favorite = Favorite % 2;
    print(Favorite);
  }

  Map<String, dynamic> toMap() {
    return {
      'mountain_name': name,
      'country': country,
      'Mountain_height': height,
      'mountain_photo_name':photo,
      'favorite': Favorite,
    };
  }
}

class searchengine extends ChangeNotifier{

  List<Mountains> DB_Mountains= new List<Mountains>();
  List<Mountains> DB_Mountains_readable= new List<Mountains>();
  List<Mountains> DB_Mountains_Gone_To= new List<Mountains>();
  int DB_Row_count;
  int DB_version=2;
  int index_to_read=0;
  double screenwidth=0;
  void DataToEncoded(){
      var response=data;
      for(int i=0;i<response.length;i++){
        Mountains note=Mountains(response[i]['mountain_name'],response[i]['country'],response[i]['Mountain_height'],response[i]['mountain_photo_name'],0);
        DB_Mountains.add(note);
      }
      notifyListeners();
    }
  void add10(){
    int count=0;
    int How_Much_To_Read_At_A_Time=1;
    for (index_to_read;index_to_read<DB_Mountains.length&&How_Much_To_Read_At_A_Time!=count;index_to_read++){
      if(DB_Mountains[index_to_read].Favorite==0){
      DB_Mountains_readable.add(DB_Mountains[index_to_read]);
      count++;
      }
    }
    notifyListeners();
  }
    int  NumSelected(var List){
      int selected=0;
      for(int i=0;i<List.length;i++){
        if(List[i].Selected==1){
          selected++;
        }}
      return selected;
    }
    bool SelectedExist(var List){
      for(int i=0;i<List.length;i++){
        if(List[i].Selected==1){
          print(true);
          return true;
        }}
      print(false);
      return false;
    }
    void Selected(var List,int index){
      List[index].toggleSelected();
      notifyListeners();
    }

    void ShareSelected(var List){
      var ToShare = [];
      List.forEach((element) {if(element.Selected==1){
        element.Selected=0;
        ToShare.add(element);
      }});
      String ToShareString="";
      ToShare.forEach((element) {ToShareString=ToShareString+'''
Mountain name: '''+element.name+'''\n
Mountain height: '''+element.height+'''\n
Mountain country: '''+element.country+"\n\n"; });
      Share.share(ToShareString);
      notifyListeners();
    }
  Future<void> Toggle_done(var List) async {
    var ToBeMarkedAsDone = [];
    List.forEach((element) {if(element.Selected==1){
      element.Selected=0;
      ToBeMarkedAsDone.add(element);
    }});

    ToBeMarkedAsDone.forEach((element) {
      element.toggleFavorite();
    });
    await UpdateDB(List);
    await GetGoneTo();
    clearold();
    await ReadDB();
    notifyListeners();
  }
  void clearold(){
    index_to_read=0;
    DB_Mountains.clear();
    DB_Mountains_readable.clear();
  }
  Future<void> CheckNewDatabaseVersion() async {
    int oldversion=999;
    bool exists;
    exists=await CheckIfDatabaseExists();
    try {
      if(exists){
      await InitDB();
      final Database db = await database;
      print(oldversion);
      oldversion = await db.getVersion();
      print(oldversion);}
    }
    catch (_) {}
    if (oldversion<DB_version&&oldversion!=0){
      print("Reading old Database");
      await ReadDB();
      print("deleting old Database");
      await DeleteDataBase();
      print("creating new Database");
      await CreateDB();
      print("updating new Database");
      await UpdateDB(DB_Mountains);
    }else{print("Database is at last version");}
  }
  Future<void> DeleteDataBase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseName);
    var db = await openDatabase(path);
      db.close();
      //delete the old database so you can copy the new one
      await deleteDatabase(path);
  }
  //database values
  String DatabaseName="mountains_database.db";
  String TableName="mountain";
  Future<Database> database;
  //create the DB+Get refrence for it

  Future<void> CreateDB() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), DatabaseName),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.

        return db.execute(
          "CREATE TABLE mountain(mountain_name TEXT,country TEXT,Mountain_height TEXT,mountain_photo_name TEXT,favorite INTEGER,PRIMARY KEY (mountain_name,country,Mountain_height))",
        );

      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: DB_version,

    );

  }
  Future<void> InitDB() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), DatabaseName),
    );
  }
  Future<bool> CheckIfDatabaseExists() async {
    return databaseFactory.databaseExists(join(await getDatabasesPath(), DatabaseName));
  }


  Future<void> UpdateDB(var update) async {
    
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    print("\n\n\n\n\n\n\ninserting to DB");

    var batch = db.batch();
    update.forEach((element) async {

      batch.insert(TableName, element.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
      //await db.insert(TableName,element.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    }
      );
    print("batch.commit is excuting");
    await batch.commit(noResult: true);
    print("Done");
    notifyListeners();
  }
  Future<void> UpdateDB_gone_to() async {

    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    print("\n\n\n\n\n\n\ninserting to DB");

    var batch = db.batch();
    DB_Mountains_Gone_To.forEach((element) async {

      batch.insert(TableName, element.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
      //await db.insert(TableName,element.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    }
    );
    print("batch.commit is excuting");
    await batch.commit(noResult: true);
    print("Done");
  }
  Future<void> ReadDB() async {
    clearold();
    // Get a reference to the database.
    final Database db = await database;


    final List<Map<String, dynamic>> maps=await db.rawQuery("SELECT * FROM mountain ORDER BY country ASC");

    // Convert the List<Map<String, dynamic> into a List<Note>.

    DB_Mountains = List.generate(maps.length, (i) {
      return Mountains(
        maps[i]['mountain_name'],
        maps[i]['country'],
        maps[i]['Mountain_height'],
        maps[i]['mountain_photo_name'],
        maps[i]['favorite'],
      );
    });

    for(int i=0;i<10;i++){
    add10();}

    notifyListeners();
  }
 
  Future<void> Vaccum() async {
    await CreateDB();
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Notes.
    // Convert the List<Map<String, dynamic> into a List<Note>.
    final List<Map<String, dynamic>> maps=await db.rawQuery('''VACUUM''');
    notifyListeners();
  }

  Future<void> GetGoneTo() async {
    await CreateDB();
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Notes.
    // Convert the List<Map<String, dynamic> into a List<Note>.
    final List<Map<String, dynamic>> maps=await db.rawQuery('''SELECT * FROM mountain where favorite = ? ORDER BY country ASC''',[1]);
    DB_Mountains_Gone_To = List.generate(maps.length, (i) {
      return Mountains(
        maps[i]['mountain_name'],
        maps[i]['country'],
        maps[i]['Mountain_height'],
        maps[i]['mountain_photo_name'],
        maps[i]['favorite'],
      );
    });
    notifyListeners();
  }
  Future<void> RowsCount() async {
    // Get a reference to the database.
    await CreateDB();
    Database db = await database;
    // Query the table for all The Notes.
    // Convert the List<Map<String, dynamic> into a List<Note>.
    DB_Row_count= Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM mountain'));
    print(DB_Row_count);
  }
  Future<void> getspecificcountry(String countryname) async {
    await CreateDB();
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Notes.
    // Convert the List<Map<String, dynamic> into a List<Note>.
    final List<Map<String, dynamic>> maps=await db.rawQuery("SELECT * FROM mountain WHERE country LIKE '${countryname}%' ORDER BY country ASC");
    DB_Mountains_readable = List.generate(maps.length, (i) {
      return Mountains(
        maps[i]['mountain_name'],
        maps[i]['country'],
        maps[i]['Mountain_height'],
        maps[i]['mountain_photo_name'],
        maps[i]['favorite'],
      );
    });

    notifyListeners();
  }
  Future<void> getspecificcountry_gone_too(String countryname) async {
    await CreateDB();
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Notes.
    // Convert the List<Map<String, dynamic> into a List<Note>.
    final List<Map<String, dynamic>> maps=await db.rawQuery("SELECT * FROM mountain WHERE country LIKE '${countryname}%' AND favorite = '${1}' ORDER BY country ASC");
    DB_Mountains_Gone_To = List.generate(maps.length, (i) {
      return Mountains(
        maps[i]['mountain_name'],
        maps[i]['country'],
        maps[i]['Mountain_height'],
        maps[i]['mountain_photo_name'],
        maps[i]['favorite'],
      );
    });

    notifyListeners();
  }

}
