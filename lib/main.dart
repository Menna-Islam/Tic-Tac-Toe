import 'package:flutter/material.dart';

void main() {
  runApp(TicTacToe());
}

class TicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Return the MaterialApp widget, the root of the Flutter app
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlayerSelectionScreen(), // Set the home screen as PlayerSelectionScreen
    );
  }
}

class PlayerSelectionScreen extends StatelessWidget {  // Screen for selecting player symbol (X or O)
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // widget
      appBar: AppBar(
        title: Text('Choose Your Symbol'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push( // on press method navigates to TicTacToeGame screen with the 'X' symbol
                  context,
                  MaterialPageRoute(builder: (context) => TicTacToeGame(playerSymbol: 'X')),
                );
              },
              child: Text('Player One: X'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {  // on press method navigates to TicTacToeGame screen with the 'O' symbol
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicTacToeGame(playerSymbol: 'O')),
                );
              },
              child: Text('Player One: O'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {   //the game screen
  final String playerSymbol;   //the player symbol passed from previous widget

  TicTacToeGame({required this.playerSymbol});  //constructor

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();   //creating the game state
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<List<String>> _board = List.generate(3, (_) => List.filled(3, ''));  //3x3 board
  String _currentPlayer = ''; // X , O or null in draw
  String? _winner;
  int playerXScore = 0;
  int playerOScore = 0;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {  //called in the first run of the app , and each time we rematch
    _board = List.generate(3, (_) => List.filled(3, ''));  //reset game board
    _currentPlayer = widget.playerSymbol;  //reset player symbol
    _winner = null;  //reset winner
  }

  void _markBox(int row, int col) {      // Function to mark the selected box on the game board
    if (_board[row][col].isEmpty && _winner == null) {  //check if the selected cell is empty and there is no winner yet , so the player can mark that box
      setState(() {
        _board[row][col] = _currentPlayer;     // Mark the box with the current player's symbol
        _checkWinner(row, col);                // check for the winner after marking the box
        if (_winner == null) {
          _checkDraw();                        // Check for draw after marking box
        }
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';   // Switch to the other player
      });
    }
  }

  void _checkDraw() {
    if (_board.every((row) => row.every((cell) => cell.isNotEmpty))) {   //check if every cell is not empty
      setState(() {
        _winner = 'No one, Draw';
      });
    }
  }

  void _checkWinner(int row, int col) {
    String player = _board[row][col];   //get the current player symbol
    bool rowWin = _board[row].every((element) => element == player);  //entire row filled with same symbol
    bool colWin = _board.every((row) => row[col] == player);           // same but for col
    bool diagonal1Win = _board.every((row) => row[_board.indexOf(row)] == player);   //same but diagonal
    bool diagonal2Win = _board.every((row) => row[_board.length - 1 - _board.indexOf(row)] == player);

    if (rowWin || colWin || (row == col && diagonal1Win) || (row + col == 2 && diagonal2Win)) {  //if any state of those happened
      setState(() {
        _winner = player;    //that symbol is the winner
        _updateScore();
      });
    }
  }

  void _updateScore() {
    if (_winner == 'X') {
      playerXScore++;
    } else if (_winner == 'O') {
      playerOScore++;
    }
  }

  void _resetGame() {  //rematch
    setState(() {
      _initializeBoard();
    });
  }

  void _viewResults() {
    Navigator.push(   //navigates us to the results screen to view scores or reset it
      context,
      MaterialPageRoute(            // Pass relevant data to the results screen
        builder: (context) => ResultsScreen(playerXScore: playerXScore, playerOScore: playerOScore, onReset: _resetScores),
      ),
    );
  }

  Future<void> _resetScores() async {
    bool confirmReset = await showDialog(   //confirmation dialog
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Scores'),
          content: Text('Are you sure you want to reset scores to zero?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // user does not want to reset scores
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // user confirmed reset scores
              },
              child: Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmReset == true) {
      setState(() {
        playerXScore = 0;
        playerOScore = 0;
      });

      // navigates us back to the game screen
      Navigator.pop(context);
    }
  }

  Widget _buildGridCell(int row, int col) {   // clickable grid cell with the player's symbol
    return GestureDetector(
      onTap: () => _markBox(row, col),       //marking the box with symbol when user clicks the cell
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: Text(
            _board[row][col],
            style: TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {   // the gamescreen layout
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _winner != null
                ? Text('Winner: $_winner', style: TextStyle(fontSize: 24))
                : SizedBox(),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                int row = index ~/ 3;
                int col = index % 3;
                return _buildGridCell(row, col);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Rematch'),
              onPressed: _resetGame,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Results'),
              onPressed: _viewResults,
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {  // results screen
  final int playerXScore;
  final int playerOScore;
  final VoidCallback onReset;     // Callback function to reset scores

  ResultsScreen({required this.playerXScore, required this.playerOScore, required this.onReset}); //constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(   //building layout
      appBar: AppBar(
        title: Text('Game Results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Player X Score: $playerXScore', style: TextStyle(fontSize: 24)),
            Text('Player O Score: $playerOScore', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Reset Score'),
              onPressed: onReset,   //calling the reset function when user press that button
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Back to Game'),
              onPressed: () {
                Navigator.pop(context); // navigates us back to the game screen without resetting scores
              },
            ),
          ],
        ),
      ),
    );
  }
}
