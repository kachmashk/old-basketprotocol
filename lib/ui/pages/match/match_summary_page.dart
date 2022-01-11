import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/utils/orientation.dart';
import 'package:basket_protocol/core/models/match.dart';
import 'package:basket_protocol/ui/widgets/match_summary_table.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/ui/widgets/delete_activity_dialog.dart';

class MatchSummaryPage extends StatefulWidget {
  MatchSummaryPage({Key key, @required this.matchData}) : super(key: key);
  final Match matchData;

  @override
  _MatchSummaryPageState createState() => _MatchSummaryPageState();
}

class _MatchSummaryPageState extends State<MatchSummaryPage> {
  User user;

  @override
  void initState() {
    super.initState();
    Orientations.lockLandscapeMode();
  }

  @override
  void dispose() {
    super.dispose();
    Orientations.lockPortraitMode();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);

    return WillPopScope(
      onWillPop: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MatchSetupPage(),
          ),
          (route) => false),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MatchSetupPage(),
              ),
              (route) => false)),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'delete Record',
          onPressed: () => buildDeleteActivityDialog(
              context, 'matches', user.id, widget.matchData.id),
        ),
      ],
      title: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            '${widget.matchData.teamOne.name} - ${widget.matchData.teamOne.points} : ${widget.matchData.teamTwo.points} - ${widget.matchData.teamTwo.name}',
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            MatchSummaryTable(team: widget.matchData.teamOne),
            MatchSummaryTable(team: widget.matchData.teamTwo)
          ],
        ),
      ],
    );
  }
}
