import 'package:flutter/material.dart';

import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/core/helpers/tables_counters.dart';

class ContestSummaryTable extends StatefulWidget {
  ContestSummaryTable({Key key, @required this.players}) : super(key: key);
  final List<Map<String, dynamic>> players;

  @override
  _ContestSummaryTableState createState() => _ContestSummaryTableState();
}

class _ContestSummaryTableState extends State<ContestSummaryTable> {
  int _sortColumnIndex = 1;
  bool _isSorted = true;

  void _sort(List _players, String _columnToBeSortedBy) {
    switch (_columnToBeSortedBy) {
      case 'zoneOneScored':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                  (a, b) => b['zoneOneScored'].compareTo(a['zoneOneScored']));
              _sortColumnIndex = 1;
              _isSorted = false;

              return;
            }

            _players.sort(
                (a, b) => a['zoneOneScored'].compareTo(b['zoneOneScored']));
            _sortColumnIndex = 1;
            _isSorted = true;

            return;
          });
        }
        break;

      case 'zoneTwoScored':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                  (a, b) => b['zoneTwoScored'].compareTo(a['zoneTwoScored']));
              _sortColumnIndex = 2;
              _isSorted = false;

              return;
            }

            _players.sort(
                (a, b) => a['zoneTwoScored'].compareTo(b['zoneTwoScored']));
            _sortColumnIndex = 2;
            _isSorted = true;

            return;
          });
        }
        break;

      case 'zoneThreeScored':
        {
          setState(() {
            if (_isSorted) {
              _players.sort((a, b) =>
                  b['zoneThreeScored'].compareTo(a['zoneThreeScored']));
              _sortColumnIndex = 3;
              _isSorted = false;

              return;
            }

            _players.sort(
                (a, b) => a['zoneThreeScored'].compareTo(b['zoneThreeScored']));
            _sortColumnIndex = 3;
            _isSorted = true;

            return;
          });
        }
        break;

      case 'zoneFourScored':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                  (a, b) => b['zoneFourScored'].compareTo(a['zoneFourScored']));
              _sortColumnIndex = 4;
              _isSorted = false;

              return;
            }

            _players.sort(
                (a, b) => a['zoneFourScored'].compareTo(b['zoneFourScored']));
            _sortColumnIndex = 4;
            _isSorted = true;

            return;
          });
        }
        break;

      case 'zoneFiveScored':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                  (a, b) => b['zoneFiveScored'].compareTo(a['zoneFiveScored']));
              _sortColumnIndex = 5;
              _isSorted = false;

              return;
            }

            _players.sort(
                (a, b) => a['zoneFiveScored'].compareTo(b['zoneFiveScored']));
            _sortColumnIndex = 5;
            _isSorted = true;

            return;
          });
        }
        break;

      case 'scored':
        {
          setState(() {
            if (_isSorted) {
              _players.sort((a, b) => b['scored'].compareTo(a['scored']));
              _sortColumnIndex = 6;
              _isSorted = false;

              return;
            }

            _players.sort((a, b) => a['scored'].compareTo(b['scored']));
            _sortColumnIndex = 6;
            _isSorted = true;

            return;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: 200,
      transitionXBegin: 400.0,
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: 28,
              columnSpacing: 14,
              horizontalMargin: 12,
              headingRowHeight: 26,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _isSorted,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    '3pts contest',
                  ),
                ),
                DataColumn(
                  label: Text('1st zone'),
                  onSort: (i, b) => _sort(
                    widget.players,
                    'zoneOneScored',
                  ),
                ),
                DataColumn(
                  label: Text('2nd zone'),
                  onSort: (i, b) => _sort(
                    widget.players,
                    'zoneTwoScored',
                  ),
                ),
                DataColumn(
                  label: Text('3rd zone'),
                  onSort: (i, b) => _sort(
                    widget.players,
                    'zoneThreeScored',
                  ),
                ),
                DataColumn(
                  label: Text('4th zone'),
                  onSort: (i, b) => _sort(
                    widget.players,
                    'zoneFourScored',
                  ),
                ),
                DataColumn(
                  label: Text('5th zone'),
                  onSort: (i, b) => _sort(
                    widget.players,
                    'zoneFiveScored',
                  ),
                ),
                DataColumn(
                  label: Text('total'),
                  onSort: (i, b) => _sort(
                    widget.players,
                    'scored',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'total %',
                  ),
                ),
              ],
              rows: widget.players
                  .map<DataRow>(
                    (player) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(
                            player['name'],
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['zoneOneScored']}/${player['zoneOneMissed']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['zoneTwoScored']}/${player['zoneTwoMissed']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['zoneThreeScored']}/${player['zoneThreeMissed']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['zoneFourScored']}/${player['zoneFourMissed']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['zoneFiveScored']}/${player['zoneFiveMissed']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.throwsTotal(
                              player,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.throwsTotalPercentage(
                              player,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
