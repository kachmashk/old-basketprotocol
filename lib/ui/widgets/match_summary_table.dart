import 'package:flutter/material.dart';

import 'package:basket_protocol/core/models/team.dart';
import 'package:basket_protocol/core/helpers/tables_counters.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';

class MatchSummaryTable extends StatefulWidget {
  MatchSummaryTable({Key key, this.team, this.players}) : super(key: key);
  final Team team;
  final players;

  @override
  _MatchSummaryTableState createState() => _MatchSummaryTableState();
}

class _MatchSummaryTableState extends State<MatchSummaryTable> {
  String _teamName;
  int _sortColumnIndex = 1;
  bool _isSorted = true;

  var _players = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();

    if (widget.team == null) {
      _teamName = '';
      _players = widget.players;

      return;
    }

    _teamName = widget.team.name;
    _players = widget.team.players;
  }

  void _sort(List _players, String _columnToBeSortedBy) {
    switch (_columnToBeSortedBy) {
      case 'points':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['points'].compareTo(
                  a['points'],
                ),
              );
              _sortColumnIndex = 1;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['points'].compareTo(
                b['points'],
              ),
            );
            _sortColumnIndex = 1;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'assists':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['assists'].compareTo(
                  a['assists'],
                ),
              );
              _sortColumnIndex = 2;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['assists'].compareTo(
                b['assists'],
              ),
            );
            _sortColumnIndex = 2;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'rebounds':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['rebounds'].compareTo(
                  a['rebounds'],
                ),
              );
              _sortColumnIndex = 3;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['rebounds'].compareTo(
                b['rebounds'],
              ),
            );
            _sortColumnIndex = 3;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'blocks':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['blocks'].compareTo(
                  a['blocks'],
                ),
              );
              _sortColumnIndex = 4;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['blocks'].compareTo(
                b['blocks'],
              ),
            );
            _sortColumnIndex = 4;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'steals':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['steals'].compareTo(
                  a['steals'],
                ),
              );
              _sortColumnIndex = 5;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['steals'].compareTo(
                b['steals'],
              ),
            );
            _sortColumnIndex = 5;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'turnovers':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['turnovers'].compareTo(
                  a['turnovers'],
                ),
              );
              _sortColumnIndex = 6;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['turnovers'].compareTo(
                b['turnovers'],
              ),
            );
            _sortColumnIndex = 6;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'twoPointsMade':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['twoPointsMade'].compareTo(
                  a['twoPointsMade'],
                ),
              );
              _sortColumnIndex = 7;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['twoPointsMade'].compareTo(
                b['twoPointsMade'],
              ),
            );
            _sortColumnIndex = 7;
            _isSorted = true;

            return;
          });
        }
        break;
      case 'threePointsMade':
        {
          setState(() {
            if (_isSorted) {
              _players.sort(
                (a, b) => b['threePointsMade'].compareTo(
                  a['threePointsMade'],
                ),
              );
              _sortColumnIndex = 9;
              _isSorted = false;

              return;
            }

            _players.sort(
              (a, b) => a['threePointsMade'].compareTo(
                b['threePointsMade'],
              ),
            );
            _sortColumnIndex = 9;
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
      curve: Curves.easeIn,
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
                  label: Text(_teamName),
                ),
                DataColumn(
                  label: Text('points'),
                  onSort: (i, b) => _sort(
                    _players,
                    'points',
                  ),
                ),
                DataColumn(
                  label: Text('assists'),
                  onSort: (i, b) => _sort(
                    _players,
                    'assists',
                  ),
                ),
                DataColumn(
                  label: Text('rebounds'),
                  onSort: (i, b) => _sort(
                    _players,
                    'rebounds',
                  ),
                ),
                DataColumn(
                  label: Text('blocks'),
                  onSort: (i, b) => _sort(
                    _players,
                    'blocks',
                  ),
                ),
                DataColumn(
                  label: Text('steals'),
                  onSort: (i, b) => _sort(
                    _players,
                    'steals',
                  ),
                ),
                DataColumn(
                  label: Text('turnovers'),
                  onSort: (i, b) => _sort(
                    _players,
                    'turnovers',
                  ),
                ),
                DataColumn(
                  label: Text('2pts'),
                  onSort: (i, b) => _sort(
                    _players,
                    'twoPointsMade',
                  ),
                ),
                DataColumn(label: Text('2p%')),
                DataColumn(
                  label: Text('3pts'),
                  onSort: (i, b) => _sort(
                    _players,
                    'threePointsMade',
                  ),
                ),
                DataColumn(
                  label: Text(
                    '3p%',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'fg',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'fg%',
                  ),
                ),
              ],
              rows: _players
                  .map<DataRow>(
                    (player) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(
                            '${player['name']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['points']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['assists']}',
                          ),
                        ),
                        DataCell(Text(
                          '${player['rebounds']}',
                        )),
                        DataCell(
                          Text(
                            '${player['blocks']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['steals']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${player['turnovers']}',
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.twoPointersTotal(
                              player,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.twoPointersPercentageTotal(
                              player,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.threePointersTotal(
                              player,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.threePointersPercentageTotal(
                              player,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.fieldGoalsTotal(
                              player,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            TablesCounters.fieldGoalsPercentageTotal(
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
