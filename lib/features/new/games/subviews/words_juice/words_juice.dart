import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show DeviceOrientation, rootBundle;
import 'package:test1/data/repo/game_repository.dart';
import 'package:test1/features/new/games/subviews/words_juice/components/background.dart';
import 'package:test1/features/new/profile/subviews/my_trophies/ui/my_trophies.dart';
import 'package:test1/global/common/toast.dart';

class WordsJuice extends StatelessWidget {
  final UserModel user;

  WordsJuice({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('sdsd'),
      // ),
      body: GameWidget.controlled(
        gameFactory: () => WordsJuiceGame(
          user: user,
        ),
        overlayBuilderMap: {
          'start_view': (context, game) => Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.black,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Scores : ${(game as WordsJuiceGame).score}',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'ValMore',
                            color: Colors.white)
                    ),
                    Text('Words Juice',
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'ValMore',
                            color: Colors.white)),

                      SizedBox(
                      height: 50
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          (game as WordsJuiceGame).reset();
                          game.overlays.remove('start_view');
                        },
                        child: Text('Start',
                            style: TextStyle(fontFamily: 'ValMore',
                            fontSize: 32
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 50
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text('1. The player spells the correct word by filling in the letters. Each misspelling will cost you a chance to add juice to the juice glass. Spell the correct word within three misspellings and the game passes. Three misspellings end, the juice cup overflows, and the game ends.\n2. Click "Hint me!" on the screen. Button, consume three misspellings, will receive a hint about the meaning of the word.\n3. Skip the word and click the refresh button in the upper right corner.',
                      
                      style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'ValMore',
                              color: Colors.white)  
                      ),
                    )
                  ],
                ),
              ),
          'quit_button': (context, game) => IconButton(
                icon: const Icon(Icons.arrow_back, size: 52),
                onPressed: () {
                  Navigator.pop(context);
                  Flame.device.setOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.portraitUp
                  ]);
                },
              ),
          'reset_button': (context, game) => Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.refresh, size: 52),
                  onPressed: () {
                    (game as WordsJuiceGame).reset();
                  },
                ),
              ),
          'game_lost': (context, game) => Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Game Over',
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'ValMore',
                            color: Colors.white)),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      onPressed: () {
                        (game as WordsJuiceGame).reset();
                        game.text.text =
                            'Score : ${game.score} Health : ${game.health}';
                        game.overlays.remove('game_lost');
                      },
                      child: Text('Try Again',
                          style: TextStyle(fontFamily: 'ValMore')),
                    )
                  ],
                ),
              ),
          'game_won': (context, game) => Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Congratulations!',
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'ValMore',
                            color: Colors.white)),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      onPressed: () {
                        (game as WordsJuiceGame).reset();
                        game.overlays.remove('game_won');
                      },
                      child: Text('Next Word',
                          style: TextStyle(fontFamily: 'ValMore')),
                    )
                  ],
                ),
              ),
          'hint_screen': (context, game) => Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(game as WordsJuiceGame).currentWord[2]}',
                        style: TextStyle(fontSize: 12, fontFamily: 'ValMore')),
                  ],
                ),
              ),
        },
        initialActiveOverlays: [ 'reset_button', 'start_view','quit_button',],
      ),
    );
  }
}

class WordsJuiceGame extends FlameGame {
  List<List<dynamic>> words = [];
  List<dynamic> currentWord = [];
  List<SpriteComponent> letters = [];
  List<ButtonComponent> keyBoard = [];

  int health = 4;

  int correctLettersNumber = 0;

  int score = 0;

  bool isShowingHint = false;

  late final SpriteComponent juice = SpriteComponent.fromImage(
    priority: 100,
    images.fromCache('backgrounds/words_juice/juice_$health.png'),
    size: Vector2(this.size.x / 6, this.size.y / 4),
    position: Vector2(this.size.x / 2, this.size.y / 4 + 20),
    anchor: Anchor.center,
  );

  final background = BackgroundTile();

  late final TextComponent text;

  Future getScore() async {
    final int score = await GameRepository()
        .getScore(user.id)
        .then((value) => value?.wordsJuiceScore ?? 0);
    return score;
  }

  Future updateScore() async {
    await GameRepository().updateScore({'wordsJuiceScore': score}, user.id);
  }

  Future loadCsvData() async {
    final rawData = await rootBundle.loadString('assets/words.csv');
    words = await const CsvToListConverter().convert(rawData);
  }

  final UserModel user;
  WordsJuiceGame({required this.user});

  @override
  Future<void> onLoad() async {
    Flame.device.setOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    await images.loadAllImages();

    score = await getScore();

    await loadCsvData();

    WordField();

    generateKeyBoard();

    add(background);

    add(juice);

    text = TextComponent(
        priority: 1,
        anchor: Anchor.center,
        text: 'Score : $score Health : $health',
        position: Vector2(this.size.x / 2, this.size.y / 2 - 60),
        textRenderer: TextPaint(
            style: TextStyle(
                fontFamily: 'ValMore', color: Colors.black, fontSize: 20)));

    add(text);
  }

  String secondFormat(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return ('$minutes:$remainingSeconds');
  }

  void WordField() {
    currentWord = words[random.nextInt(words.length) + 1];

    final backgroundPadding = 30;
    final backgroundWidth = this.size.x - backgroundPadding;
    final backgroundHeight = this.size.y / 2 - backgroundPadding;

    final wordLength = currentWord[1].length;

    final defaultLetterWidth = this.size.x / 10;
    final letterWidth = wordLength * defaultLetterWidth > backgroundWidth
        ? backgroundWidth / wordLength
        : defaultLetterWidth;

    final background = SpriteComponent.fromImage(
        images.fromCache('backgrounds/words_juice/desk.png'))
      ..size = Vector2(backgroundWidth, backgroundHeight)
      ..position = Vector2(backgroundPadding / 2, backgroundPadding / 2);

    background.add(ButtonComponent(
      button: SpriteComponent.fromImage(
          images.fromCache('backgrounds/words_juice/button.png'),
          size: Vector2(backgroundWidth / 5, backgroundHeight / 5),
          children: [
            TextComponent(
                priority: 3,
                text: 'hint me! (3 health)',
                position: Vector2(10, backgroundHeight / 10 - 12.5),
                anchor: Anchor.topLeft,
                textRenderer: TextPaint(
                    style: TextStyle(
                        fontFamily: 'ValMore',
                        color: Colors.black,
                        fontSize: 20)))
          ]),
      buttonDown: SpriteComponent.fromImage(
          images.fromCache('backgrounds/words_juice/button_1.png'),
          size: Vector2(backgroundWidth / 5, backgroundHeight / 5),
          children: [
            TextComponent(
                priority: 3,
                text: 'hint me! (3 health)',
                position: Vector2(10, backgroundHeight / 10),
                anchor: Anchor.topLeft,
                textRenderer: TextPaint(
                    style: TextStyle(
                        fontFamily: 'ValMore',
                        color: Colors.black,
                        fontSize: 20)))
          ]),
      position: Vector2(backgroundWidth - backgroundWidth / 5 - 20,
          backgroundHeight - backgroundHeight / 5 - 25),
      onPressed: () {
        if (health <= 3) {
          showToast(message: 'Not enough health!');
          return;
        }

        isShowingHint = true;

        health -= 3;
        text.text = 'Score : $score Health : $health';

        overlays.add('hint_screen');
      },
    ));

    add(background);

    for (int i = 0; i < wordLength; i++) {
      final letter = SpriteComponent.fromImage(
        key: ComponentKey.named('$i,${currentWord[1][i]}'),
        children: [
          TextComponent(
              text: currentWord[1][i],
              anchor: Anchor.center,
              position: Vector2(letterWidth / 2, letterWidth / 2),
              textRenderer: TextPaint(
                  style: TextStyle(
                      fontFamily: 'ValMore',
                      color: Colors.transparent,
                      fontSize: letterWidth)))
        ],
        images.fromCache('backgrounds/words_juice/card_1.png'),
      )
        ..size = Vector2(letterWidth, letterWidth)
        ..position = Vector2(
            background.position.x + i * letterWidth, background.position.y);

      letters.add(letter);
      add(letter);
    }
  }

  void reset() {
    currentWord = words[random.nextInt(words.length) + 1];

    if (isShowingHint) {
      overlays.remove('hint_screen');
      isShowingHint = false;
    }

    correctLettersNumber = 0;

    letters.forEach((element) {
      element.removeFromParent();
    });

    letters.clear();

    keyBoard.forEach((element) {
      element.removeFromParent();
    });

    keyBoard.clear();

    health = 4;

    juice.sprite =
        Sprite(images.fromCache('backgrounds/words_juice/juice_$health.png'));

    WordField();
    generateKeyBoard();
  }

  void generateKeyBoard() {
    final keySize = Vector2(this.size.x / 10, this.size.x / 10);
    final keysPosition = Vector2(
        this.size.x / 2 - keySize.x / 2 * 12, this.size.y - keySize.y * 3);

    final keyBoardKeys = [
      'q',
      'w',
      'e',
      'r',
      't',
      'y',
      'u',
      'i',
      'o',
      'p',
      'a',
      's',
      'd',
      'f',
      'g',
      'h',
      'j',
      'k',
      'l',
      'z',
      'x',
      'c',
      'v',
      'b',
      'n',
      'm'
    ];

    for (int i = 1; i < 27; i++) {
      bool isPressed = false;

      int line = 0;
      int column = 0;

      if (i <= 10) {
        line = 0;
        column = i;
      } else if (i < 20) {
        line = 1;
        column = i - 10;
      } else {
        line = 2;
        column = i - 18;
      }

      final key = ButtonComponent(
        position: Vector2(keysPosition.x + column * keySize.x,
            keysPosition.y + line * keySize.y),
        size: keySize,
        button: SpriteComponent.fromImage(
          images.fromCache('backgrounds/words_juice/keyboard_$i.png'),
          size: keySize,
        ),
        buttonDown: SpriteComponent.fromImage(
          images.fromCache('backgrounds/words_juice/keyboard_down_$i.png'),
          size: keySize,
        ),
        onPressed: () async {
          //  resetWordField();
          if (isPressed) {
            showToast(message: '${keyBoardKeys[i - 1]} Already pressed!');
            return;
          }

          isPressed = true;

          final letter = keyBoardKeys[i - 1];

          if (currentWord[1].contains(letter)) {
            final correctLetters = letters.where((element) =>
                (element.children.first as TextComponent).text == letter);

            for (final letter in correctLetters) {
              correctLettersNumber += 1;
              (letter.children.first as TextComponent).textRenderer = TextPaint(
                  style: TextStyle(
                      fontFamily: 'ValMore',
                      color: Colors.black,
                      fontSize: letter.size.x / 2));

              if (correctLettersNumber == currentWord[1].length) {
                gameWon();
              }
            }

            FlameAudio.play('type.wav', volume: 1);
          } else {
            health -= 1;
            text.text = 'Score : $score Health : $health';

            FlameAudio.play('water.wav', volume: 1);

            juice.sprite = Sprite(
                images.fromCache('backgrounds/words_juice/juice_$health.png'));

            if (health == 0) {
              FlameAudio.play('lose.wav', volume: 1);

              if (isShowingHint) {
                overlays.remove('hint_screen');
                isShowingHint = false;
              }

              correctLettersNumber = 0;
              overlays.add('game_lost');
            }
          }
        },
      );
      keyBoard.add(key);
      add(key);
    }
  }

  void gameWon() async {
    FlameAudio.play('win.wav', volume: 1);
    score += 1;
    text.text = 'Score : $score';
    juice.sprite =
        Sprite(images.fromCache('backgrounds/words_juice/juice_$health.png'));
    updateScore();
    correctLettersNumber = 0;
    overlays.add('game_won');
  }
}
