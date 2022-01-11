class MockPlayers {
  static Map<String, dynamic> getStarterPlayer() {
    return {
      'name': 'player',
      'scored': 0,
      'missed': 0,
      'twoPointsMade': 0,
      'twoPointsAttempts': 0,
      'threePointsMade': 0,
      'threePointsAttempts': 0
    };
  }

  static Map<String, dynamic> getUpdatedPlayer() {
    return {
      'name': 'player',
      'points': 14,
      'scored': 8,
      'missed': 17,
      'twoPointsMade': 3,
      'twoPointsAttempts': 4,
      'threePointsMade': 1,
      'threePointsAttempts': 3
    };
  }

  static List<Map<String, dynamic>> getStarterPlayersA() {
    return ([
      {
        'name': 'player 1',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      },
      {
        'name': 'player 2',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      },
      {
        'name': 'player 3',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      }
    ]);
  }

  static List<Map<String, dynamic>> getUpdatedPlayersA() {
    return ([
      {
        'name': 'player 1',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 2,
        'twoPointsAttempts': 3,
        'threePointsMade': 1,
        'threePointsAttempts': 3
      },
      {
        'name': 'player 2',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 4,
        'twoPointsAttempts': 4,
        'threePointsMade': 5,
        'threePointsAttempts': 5
      },
      {
        'name': 'player 3',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 1,
        'twoPointsAttempts': 3,
        'threePointsMade': 2,
        'threePointsAttempts': 4
      }
    ]);
  }

  static List<Map<String, dynamic>> getStarterPlayersB() {
    return ([
      {
        'name': 'player 4',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      },
      {
        'name': 'player 5',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      },
      {
        'name': 'player 6',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 0,
        'threePointsMade': 0,
        'threePointsAttempts': 0
      }
    ]);
  }

  static List<Map<String, dynamic>> getUpdatedPlayersB() {
    return ([
      {
        'name': 'player 4',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 2,
        'threePointsMade': 1,
        'threePointsAttempts': 3
      },
      {
        'name': 'player 5',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 2,
        'twoPointsAttempts': 3,
        'threePointsMade': 0,
        'threePointsAttempts': 1
      },
      {
        'name': 'player 6',
        'scored': 0,
        'missed': 0,
        'twoPointsMade': 0,
        'twoPointsAttempts': 2,
        'threePointsMade': 1,
        'threePointsAttempts': 1
      }
    ]);
  }
}
