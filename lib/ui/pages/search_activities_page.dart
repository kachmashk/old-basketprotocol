import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:basket_protocol/core/db/match_db.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/core/db/contest_db.dart';
import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/core/helpers/casters.dart';
import 'package:basket_protocol/ui/pages/match/match_page.dart';
import 'package:basket_protocol/ui/widgets/fade_in_animation.dart';
import 'package:basket_protocol/ui/pages/contest/contest_page.dart';
import 'package:basket_protocol/ui/pages/match/match_summary_page.dart';
import 'package:basket_protocol/ui/pages/contest/contest_summary_page.dart';

class SearchActivitiesPage extends StatefulWidget {
  SearchActivitiesPage(
      {Key key,
      @required this.userId,
      this.collection,
      this.isUnfinishedActivitiesViewEnabled})
      : super(key: key);
  final String userId, collection;
  final isUnfinishedActivitiesViewEnabled;

  @override
  _SearchActivitiesPageState createState() => _SearchActivitiesPageState();
}

class _SearchActivitiesPageState extends State<SearchActivitiesPage> {
  var _fetchedData = <dynamic>[];

  @override
  Widget build(BuildContext context) {
    if (widget.isUnfinishedActivitiesViewEnabled != null) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: _buildUnfinishedActivitiesAppBar(),
          body: TabBarView(
            children: <Widget>[
              _buildUnfinishedActivitiesBody('contests'),
              _buildUnfinishedActivitiesBody('matches')
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildSearchActivitiesPageAppBar(),
      body: _buildSearchActivitiesPageBody(),
    );
  }

  Widget _buildSearchActivitiesPageAppBar() {
    return AppBar(
      title: Text(
        'search your ${widget.collection}',
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => showSearch(
            context: context,
            delegate: DataSearch(
              fetchedDocuments: _fetchedData,
              collection: widget.collection,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSearchActivitiesPageBody() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(widget.userId)
          .collection(widget.collection)
          .where('isFinished', isEqualTo: true)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshots) {
        if (snapshots.hasError) {
          return Center(
            child: Text(
              snapshots.error.toString(),
            ),
          );
        }

        if (widget.collection == 'contests') {
          _fetchedData = Casters.castToContestsList(snapshots.data.documents);

          return _fetchedData.isEmpty
              ? Center(
                  child: Text(
                    'no contests found',
                  ),
                )
              : ListView.builder(
                  itemCount: _fetchedData.length,
                  itemBuilder: (context, index) => FadeInAnimation(
                    delay: 200,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: ListTile(
                      onTap: () => _goToSummary(
                        context,
                        widget.collection,
                        _fetchedData[index],
                      ),
                      title: Text(
                          '${_fetchedData.indexOf(_fetchedData[index]) + 1}. ${_fetchedData[index].title}'),
                    ),
                  ),
                );
        }

        _fetchedData = Casters.castToMatchesList(snapshots.data.documents);

        return _fetchedData.isEmpty
            ? Center(
                child: Text(
                  'no matches found',
                ),
              )
            : ListView.builder(
                itemCount: _fetchedData.length,
                itemBuilder: (context, index) => FadeInAnimation(
                  delay: 200,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: ListTile(
                    onTap: () => _goToSummary(
                      context,
                      widget.collection,
                      _fetchedData[index],
                    ),
                    title: Text(
                      '${_fetchedData.indexOf(_fetchedData[index]) + 1}. ${_fetchedData[index].title}',
                    ),
                  ),
                ),
              );
      },
    );
  }

  Widget _buildUnfinishedActivitiesAppBar() {
    return AppBar(
      title: Text('unfinished activities'),
      bottom: TabBar(
        tabs: <Tab>[
          Tab(
            text: 'contests',
          ),
          Tab(
            text: 'matches',
          ),
        ],
      ),
    );
  }

  Widget _buildUnfinishedActivitiesBody(String _collection) {
    if (_collection == 'contests') {
      return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userId)
            .collection('contests')
            .where('isFinished', isEqualTo: false)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.hasError) {
            return Center(
              child: Text(
                snapshots.error.toString(),
              ),
            );
          }

          _fetchedData = Casters.castToContestsList(snapshots.data.documents);

          return _fetchedData.isEmpty
              ? Center(
                  child: Text(
                    'no unfinished contests found',
                  ),
                )
              : ListView.builder(
                  itemCount: _fetchedData.length,
                  itemBuilder: (context, index) => FadeInAnimation(
                    delay: 200,
                    transitionXBegin: 0.0,
                    curve: Curves.ease,
                    child: ExpansionTile(
                      title: Text(
                        '${_fetchedData.indexOf(_fetchedData[index]) + 1}. ${_fetchedData[index].title}',
                      ),
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.play_arrow),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContestPage(
                                          contestData: _fetchedData[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text('continue'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.done),
                                    onPressed: () {
                                      Contest _contestData =
                                          _fetchedData[index];
                                      _contestData.update({'isFinished': true});

                                      ContestDB.updateContestDocument(
                                          widget.userId, _contestData);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(
                                      'mark as finished',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.view_list),
                                    onPressed: () => _goToSummary(
                                      context,
                                      'contests',
                                      _fetchedData[index],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text('summary'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
        },
      );
    }

    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(widget.userId)
          .collection('matches')
          .where('isFinished', isEqualTo: false)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshots) {
        if (snapshots.hasError) {
          return Center(
            child: Text(
              snapshots.error.toString(),
            ),
          );
        }

        _fetchedData = Casters.castToMatchesList(snapshots.data.documents);

        return _fetchedData.isEmpty
            ? Center(
                child: Text(
                  'no unfinished matches found',
                ),
              )
            : ListView.builder(
                itemCount: _fetchedData.length,
                itemBuilder: (context, index) => FadeInAnimation(
                  delay: 200,
                  transitionXBegin: 0.0,
                  curve: Curves.ease,
                  child: ExpansionTile(
                    title: Text(
                      '${_fetchedData.indexOf(_fetchedData[index]) + 1}. ${_fetchedData[index].title}',
                    ),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchPage(
                                        matchData: _fetchedData[index],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text('continue'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.done),
                                  onPressed: () {
                                    Match _matchData = _fetchedData[index];
                                    _matchData.update({'isFinished': true});

                                    MatchDB.updateMatchDocument(
                                        widget.userId, _matchData);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    'mark as finished',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.view_list),
                                  onPressed: () => _goToSummary(
                                    context,
                                    'matches',
                                    _fetchedData[index],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text('summary'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final fetchedDocuments;
  final collection;

  DataSearch(
      {Key key, @required this.fetchedDocuments, @required this.collection});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> _suggestions =
        fetchedDocuments.map<dynamic>((record) => record).toList();

    List<dynamic> _suggestionList = query.isEmpty
        ? _suggestions
        : _suggestions
            .where((record) => record.title.startsWith(query))
            .toList();

    return ListView.builder(
      itemCount: _suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () => _goToSummary(
          context,
          collection,
          _suggestionList[index],
        ),
        title: RichText(
          text: TextSpan(
            text: _suggestionList[index].title.substring(0, query.length),
            style: TextStyle(
              color: Color.fromRGBO(0, 125, 0, 1),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            children: <TextSpan>[
              TextSpan(
                text: _suggestionList[index].title.substring(query.length),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _goToSummary(BuildContext context, String collection, final record) {
  if (collection == 'contests') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContestSummaryPage(
          contest: record,
        ),
      ),
    );

    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MatchSummaryPage(
        matchData: record,
      ),
    ),
  );
}
