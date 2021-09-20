import 'package:flutter/material.dart';
import './model.dart';
import './utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      // showSemanticsDebugger: true,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: BoardWidget()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final _BoardWidgetState state;
  const MyHomePage({required this.state});

  @override
  Widget build(BuildContext context) {
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.column + 1) * state.tilePadding) /
        state.column;
    List<TileBox> backgroundBox = [];
    for (int r = 0; r < state.row; ++r) {
      for (int c = 0; c < state.column; ++c) {
        TileBox tile = TileBox(
          left: c * width + state.tilePadding * (c + 1),
          top: r * width + state.tilePadding * (r + 1),
          size: width,
          color: Colors.grey[400],
          text: state._board.getTile(r, c).value.toString(),
        );
        backgroundBox.add(tile);
      }
    }
    return Positioned(
        left: 0.0,
        top: 0.0,
        child: Container(
          height: state.boardSize().width,
          width: state.boardSize().width,
          decoration: BoxDecoration(color: Colors.grey),
          child: Stack(
            children: backgroundBox,
          ),
        ));
  }
}

class BoardWidget extends StatefulWidget {
  const BoardWidget({Key? key}) : super(key: key);

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  late Board _board;
  late int row;
  late int column;
  late bool _isMoving;
  late bool gameOver;
  late double tilePadding = 5.0;
  late MediaQueryData _queryData;

  Size boardSize() {
    Size size = _queryData.size;
    return Size(size.width, size.width);
  }

  @override
  void initState() {
    super.initState();
    row = 4;
    column = 4;
    _isMoving = false;
    gameOver = false;

    _board = Board(row, column);
    newGame();
  }

  void newGame() {
    setState(() {
      _board.initBoard();
    });
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    List<TileWidget> _tileWidgets = [];
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        _tileWidgets.add(TileWidget(
          state: this,
          tile: _board.getTile(r, c),
        ));
      }
    }
    List<Widget> children = [];
    children.add(MyHomePage(state: this));
    children.addAll(_tileWidgets);
    return Container(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  color: Colors.orange[100],
                  width: 120.0,
                  height: 60.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Score'), Text(_board.score.toString())],
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      newGame();
                    },
                    child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.orange[100],
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                          child: Text('New Game'),
                        )))
              ],
            ),
          ),
          Container(
            height: 40,
            child: Opacity(
              opacity: _board.gameOver() ? 1.0 : 0.0,
              child: Center(
                child: Text('Game Over'),
              ),
            ),
          ),
          Container(
            width: _queryData.size.width,
            height: _queryData.size.width,
            child: GestureDetector(
              onVerticalDragUpdate: (detail) {
                print('Something happendedy');
                if (detail.delta.distance == 0 || _isMoving) {
                  return;
                }
                _isMoving = true;
                if (detail.delta.direction > 0) {
                  setState(() {
                    _board.moveDown();
                  });
                } else {
                  setState(() {
                    _board.moveUp();
                  });
                }
              },
              onVerticalDragEnd: (d) {
                _isMoving = false;
              },
              onVerticalDragCancel: () {
                _isMoving = false;
              },
              onHorizontalDragUpdate: (d) {
                print('Something happendedx');
                if (d.delta.distance == 0 || _isMoving) {
                  return;
                }
                _isMoving = true;
                if (d.delta.direction > 0) {
                  setState(() {
                    _board.moveLeft();
                  });
                } else {
                  setState(() {
                    _board.moveRight();
                  });
                }
              },
              onHorizontalDragEnd: (d) {
                _isMoving = false;
              },
              onHorizontalDragCancel: () {
                _isMoving = false;
              },
              child: Stack(
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TileWidget extends StatefulWidget {
  final Tile tile;
  final _BoardWidgetState state;
  const TileWidget({Key? key, required this.tile, required this.state})
      : super(key: key);

  @override
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 20), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller!);
  }

  @override
  void dispose() {
    controller!.dispose();
    widget.tile.isNew = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isNew && !widget.tile.isEmpty()) {
      controller!.reset();
      controller!.forward();
      widget.tile.isNew = false;
    } else {
      controller!.animateTo(1.0);
    }
    return AnimatedTileWidget(
        tile: widget.tile, state: widget.state, animation: animation);
  }
}

class AnimatedTileWidget extends AnimatedWidget {
  final Tile tile;
  final _BoardWidgetState? state;
  AnimatedTileWidget(
      {Key? key,
      required this.tile,
      this.state,
      required Animation<double>? animation})
      : super(listenable: animation as Listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double>? animation = listenable as Animation<double>?;
    double animationValue = animation!.value;
    Size boardSize = state!.boardSize();
    double width =
        (boardSize.width - (state!.column + 1) * state!.tilePadding) /
            state!.column;
    if (tile.value == 0) {
      return Container();
    } else {
      return TileBox(
          left: (tile.column * width + state!.tilePadding * (tile.column + 1)) +
              width / 2 * (1 - animationValue),
          top: tile.row * width +
              state!.tilePadding * (tile.row + 1) +
              width / 2 * (1 - animationValue),
          size: width * animationValue,
          color: tileColors.containsKey(tile.value)
              ? tileColors[tile.value]
              : Colors.orange[50],
          text: tile.value.toString());
    }
  }
}

class TileBox extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final Color? color;
  final String text;

  const TileBox(
      {Key? key,
      required this.left,
      required this.top,
      required this.size,
      required this.color,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: left,
        top: top,
        child: (int.parse(text) != 0)
            ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                ),
                child: Center(child: Text(text)),
              )
            : Container());
  }
}
