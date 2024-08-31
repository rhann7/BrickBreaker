import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brick_breaker/audio/audio_controller.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame with HasCollisionDetection, KeyboardEvents, TapDetector {
  final AudioController audioController;
  late Ball ball;
  late List<Brick> bricks;
  bool alertPlayed = false;

  BrickBreaker({required this.audioController})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
        audioController.stopAlarm();
        audioController.stopMusic();
        overlays.add(playState.name);
        break;
      case PlayState.gameOver:
        audioController.stopAlarm();
        audioController.stopMusic();
        audioController.playSound('assets/sounds/lose.wav');
        overlays.add(playState.name);
        break;
      case PlayState.won:
        audioController.stopAlarm();
        overlays.add(playState.name);
        break;
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        break;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    audioController.startMusic();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    playState = PlayState.welcome;
  }

  void playBounceSound() {
    audioController.playSound('assets/sounds/pew1.mp3');
  }

   void playBlockBreakSound() {
    audioController.playSound('assets/sounds/pew1.mp3');
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    audioController.stopAlarm();
    alertPlayed = false;
    audioController.startMusic();

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;
    score.value = 35;

    world.add(Ball(
      difficultyModifier: difficultyModifier,
      radius: ballRadius,
      position: size / 2,
      velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
          .normalized()
        ..scale(height / 4),
      audioController: audioController,
    ));

    world.add(Bat(
      size: Vector2(batWidth, batHeight),
      cornerRadius: const Radius.circular(ballRadius / 2),
      position: Vector2(width / 2, height * 0.8)
    ));

    world.addAll([
      for (var i = 0; i < brickColors.length; i++)
        for (var j = 1; j <= 5; j++)
          Brick(
            position: Vector2(
              (i + 0.5) * brickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            color: brickColors[i],
            audioController: audioController,
          ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (score.value > 35 && !alertPlayed) {
      audioController.playLoopingSound('assets/sounds/alarm.wav');
      alertPlayed = true;
    }

    if (playState == PlayState.gameOver || playState == PlayState.won) {
      audioController.stopAlarm();
      alertPlayed = false;
    }
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event, Set<LogicalKeyboardKey> keysPressed
  ) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
        break;
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
        break;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
        break;
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}