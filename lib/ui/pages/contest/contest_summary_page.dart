import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:basket_protocol/core/models/user.dart';
import 'package:basket_protocol/utils/orientation.dart';
import 'package:basket_protocol/core/models/contest.dart';
import 'package:basket_protocol/ui/pages/match/match_setup_page.dart';
import 'package:basket_protocol/ui/widgets/contest_summary_table.dart';
import 'package:basket_protocol/ui/widgets/delete_activity_dialog.dart';

class ContestSummaryPage extends StatefulWidget {
  ContestSummaryPage({Key key, @required this.contest}) : super(key: key);
  final Contest contest;

  @override
  _ContestSummaryPageState createState() => _ContestSummaryPageState();
}

class _ContestSummaryPageState extends State<ContestSummaryPage> {
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
        body: _buildListView(),
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
          (route) => false,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'delete record',
          onPressed: () => buildDeleteActivityDialog(
            context,
            'contests',
            user.id,
            widget.contest.id,
          ),
        ),
      ],
      title: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            '${widget.contest.title}',
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            ContestSummaryTable(
              players: widget.contest.players,
            ),
            widget.contest.overtimePlayers != null
                ? ContestSummaryTable(players: widget.contest.overtimePlayers)
                : Text('')
          ],
        ),
      ],
    );
  }
}
