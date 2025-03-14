import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
}

@DataClassName('Account')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userid => integer().customConstraint('REFERENCES users(id) ON DELETE CASCADE')();
  IntColumn get platformid => integer().customConstraint('REFERENCEs platforms(id) ON DELETE CASCADE')();
  TextColumn get email => text()();
  TextColumn get username => text()();
  @override
  List<Set<Column>> get uniquekeys => [
    {platformid, email}
  ];
}

@DataClassName('platform')
class Platforms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get url => text().nullable()();
}

@DataClassName('password')
class Passwords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountid => integer().customConstraint('REFERENCES accounts(id) ON DELETE CASCADE')();
  TextColumn get encrypted => text()();
  DateTimeColumn get createat => dateTime().clientDefault(() => DateTime.now())();

}

@DriftDatabase(tables: [Users, Accounts, Platforms, Passwords])
class AppDatabase extends _$AppDatabase {
  AppDatabase(): super(_openconnection());

  @override
  int get ShemaVersion => 1;
}

LazyDatabase _openconnection() {
  return LazyDatabase(() async {
    final dbfolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbfolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}