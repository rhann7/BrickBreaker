import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:brick_breaker/audio/audio_controller.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';

class Brick extends RectangleComponent with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({
    required super.position,
    required Color color,
    required this.audioController,
  }) : super(
        size: Vector2(brickWidth, brickHeight),
        anchor: Anchor.center,
        paint: Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        children: [RectangleHitbox()],
      );

  final AudioController audioController;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints, PositionComponent other
  ) {
    super.onCollisionStart(intersectionPoints, other);
    removeFromParent();
    game.score.value++;

    audioController.playSound('assets/sounds/pew3.mp3');

    if (game.world.children.query<Brick>().length == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
    }
  }
}