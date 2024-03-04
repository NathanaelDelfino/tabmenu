// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:tabmenu/data/dessert.dart';
import 'package:tabmenu/data/dessert_data.dart';

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The file was extracted from GitHub: https://github.com/flutter/gallery
// Changes and modifications by Maxim Saplin, 2021

/// Keeps track of selected rows, feed the data into DesertsDataSource
class RestorableDessertSelections extends RestorableProperty<Set<int>> {
  Set<int> _dessertSelections = {};
  final int _selectedCount = 0;

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<Dessert> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}

int _idCounter = 0;

/// Data source implementing standard Flutter's DataTableSource abstract class
/// which is part of DataTable and PaginatedDataTable synchronous data fecthin API.
/// This class uses static collection of deserts as a data store, projects it into
/// DataRows, keeps track of selected items, provides sprting capability
class DessertDataSource extends DataTableSource {
  DessertDataSource.empty(this.context) {
    desserts = [];
  }

  DessertDataSource(this.context,
      [sortedByCalories = false,
      this.hasRowTaps = false,
      this.hasRowHeightOverrides = false,
      this.hasZebraStripes = false]) {
    desserts = ObterDesserts;
    if (sortedByCalories) {
      sort((d) => d.calories, true);
    }
  }

  final BuildContext context;
  late List<Dessert> desserts;
  // Add row tap handlers and show snackbar
  bool hasRowTaps = false;
  // Override height values for certain rows
  bool hasRowHeightOverrides = false;
  // Color each Row by index's parity
  bool hasZebraStripes = false;

  void sort<T>(Comparable<T> Function(Dessert d) getField, bool ascending) {
    desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow2 getRow(int index, [Color? color]) {
    final format = NumberFormat.decimalPercentPattern(
      locale: 'pt-br',
      decimalDigits: 0,
    );
    assert(index >= 0);
    if (index >= desserts.length) throw 'index > _desserts.length';
    final dessert = desserts[index];
    return DataRow2.byIndex(
      index: index,
      selected: false,
      color: color != null
          ? MaterialStateProperty.all(color)
          : (hasZebraStripes && index.isEven
              ? MaterialStateProperty.all(Theme.of(context).highlightColor)
              : null),
      onSelectChanged: (value) {
        if (value != null) {
          dessert.selected = value;
          notifyListeners();
        }

        _showSnackbar(context, 'Selected row ${dessert.name}');
      },

      // onSelectChanged: (value) {
      //   if (dessert.selected != value) {
      //     // _selectedCount += value! ? 1 : -1;
      //     // assert(_selectedCount >= 0);
      //     dessert.selected = value!;
      //     notifyListeners();
      //   }
      // },
      onTap: hasRowTaps
          ? () => _showSnackbar(context, 'Tapped on row ${dessert.name}')
          : null,
      onDoubleTap: hasRowTaps
          ? () => _showSnackbar(context, 'Double Tapped on row ${dessert.name}')
          : null,
      onLongPress: hasRowTaps
          ? () => _showSnackbar(context, 'Long pressed on row ${dessert.name}')
          : null,
      onSecondaryTap: hasRowTaps
          ? () => _showSnackbar(context, 'Right clicked on row ${dessert.name}')
          : null,
      onSecondaryTapDown: hasRowTaps
          ? (d) =>
              _showSnackbar(context, 'Right button down on row ${dessert.name}')
          : null,
      specificRowHeight:
          hasRowHeightOverrides && dessert.fat >= 25 ? 100 : null,
      cells: [
        DataCell(Text(dessert.name)),
        DataCell(Text('${dessert.calories}'),
            onTap: () => _showSnackbar(context,
                'Tapped on a cell with "${dessert.calories}"', Colors.red)),
        DataCell(Text(dessert.fat.toStringAsFixed(1))),
        DataCell(Text('${dessert.carbs}')),
        DataCell(Text(dessert.protein.toStringAsFixed(1))),
        DataCell(Text('${dessert.sodium}')),
        DataCell(Text(format.format(dessert.calcium / 100))),
        DataCell(Text(format.format(dessert.iron / 100))),
      ],
    );
  }

  @override
  int get rowCount => desserts.length;

  @override
  bool get isRowCountApproximate =>
      desserts.where((element) => element.selected).length > 0;

  @override
  int get selectedRowCount => 0;

  void selectAll(bool? checked) {
    for (final dessert in desserts) {
      dessert.selected = false;
    }
    // _selectedCount = (checked ?? false) ? desserts.length : 0;
    notifyListeners();
  }
}

/// Async datasource for AsynPaginatedDataTabke2 example. Based on AsyncDataTableSource which
/// is an extension to FLutter's DataTableSource and aimed at solving
/// saync data fetching scenarious by paginated table (such as using Web API)
class DessertDataSourceAsync extends AsyncDataTableSource {
  DessertDataSourceAsync() {
    print('DessertDataSourceAsync created');
  }

  DessertDataSourceAsync.empty() {
    _empty = true;
    print('DessertDataSourceAsync.empty created');
  }

  DessertDataSourceAsync.error() {
    _errorCounter = 0;
    print('DessertDataSourceAsync.error created');
  }

  bool _empty = false;
  int? _errorCounter;

  RangeValues? _caloriesFilter;

  RangeValues? get caloriesFilter => _caloriesFilter;
  set caloriesFilter(RangeValues? calories) {
    _caloriesFilter = calories;
    refreshDatasource();
  }

  final DesertsFakeWebService _repo = DesertsFakeWebService();

  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  Future<int> getTotalRecords() {
    return Future<int>.delayed(const Duration(milliseconds: 0),
        () => _empty ? 0 : ObterDessertsX3.length);
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    print('getRows($startIndex, $count)');
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    final format = NumberFormat.decimalPercentPattern(
      locale: 'en',
      decimalDigits: 0,
    );
    assert(startIndex >= 0);

    // List returned will be empty is there're fewer items than startingAt
    var x = _empty
        ? await Future.delayed(const Duration(milliseconds: 2000),
            () => DesertsFakeWebServiceResponse(0, []))
        : await _repo.getData(
            startIndex, count, _caloriesFilter, _sortColumn, _sortAscending);

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((dessert) {
          return DataRow(
            key: ValueKey<int>(dessert.id),
            //selected: dessert.selected,
            onSelectChanged: (value) {
              if (value != null) {
                setRowSelection(ValueKey<int>(dessert.id), value);
              }
            },
            cells: [
              DataCell(Text(dessert.name)),
              DataCell(Text('${dessert.calories}')),
              DataCell(Text(dessert.fat.toStringAsFixed(1))),
              DataCell(Text('${dessert.carbs}')),
              DataCell(Text(dessert.protein.toStringAsFixed(1))),
              DataCell(Text('${dessert.sodium}')),
              DataCell(Text(format.format(dessert.calcium / 100))),
              DataCell(Text(format.format(dessert.iron / 100))),
            ],
          );
        }).toList());

    return r;
  }
}

class DesertsFakeWebServiceResponse {
  DesertsFakeWebServiceResponse(this.totalRecords, this.data);

  /// THe total ammount of records on the server, e.g. 100
  final int totalRecords;

  /// One page, e.g. 10 reocrds
  final List<Dessert> data;
}

class DesertsFakeWebService {
  int Function(Dessert, Dessert)? _getComparisonFunction(
      String column, bool ascending) {
    var coef = ascending ? 1 : -1;
    switch (column) {
      case 'name':
        return (Dessert d1, Dessert d2) => coef * d1.name.compareTo(d2.name);
      case 'calories':
        return (Dessert d1, Dessert d2) => coef * (d1.calories - d2.calories);
      case 'fat':
        return (Dessert d1, Dessert d2) => coef * (d1.fat - d2.fat).round();
      case 'carbs':
        return (Dessert d1, Dessert d2) => coef * (d1.carbs - d2.carbs);
      case 'protein':
        return (Dessert d1, Dessert d2) =>
            coef * (d1.protein - d2.protein).round();
      case 'sodium':
        return (Dessert d1, Dessert d2) => coef * (d1.sodium - d2.sodium);
      case 'calcium':
        return (Dessert d1, Dessert d2) => coef * (d1.calcium - d2.calcium);
      case 'iron':
        return (Dessert d1, Dessert d2) => coef * (d1.iron - d2.iron);
    }

    return null;
  }

  Future<DesertsFakeWebServiceResponse> getData(int startingAt, int count,
      RangeValues? caloriesFilter, String sortedBy, bool sortedAsc) async {
    return Future.delayed(
        Duration(
            milliseconds: startingAt == 0
                ? 2650
                : startingAt < 20
                    ? 2000
                    : 400), () {
      var result = ObterDessertsX3;

      if (caloriesFilter != null) {
        result = result
            .where((e) =>
                e.calories >= caloriesFilter.start &&
                e.calories <= caloriesFilter.end)
            .toList();
      }

      result.sort(_getComparisonFunction(sortedBy, sortedAsc));
      return DesertsFakeWebServiceResponse(
          result.length, result.skip(startingAt).take(count).toList());
    });
  }
}

_showSnackbar(BuildContext context, String text, [Color? color]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    duration: const Duration(seconds: 1),
    content: Text(text),
  ));
}
