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
  bool isFalling = false;
  final double fallSpeed = 150;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints, PositionComponent other
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (!isFalling) {
      isFalling = true;
      game.score.value++;
      audioController.playSound('assets/sounds/pew1.mp3');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isFalling) {
      position.y += fallSpeed * dt;
      if (position.y > game.size.y) {
        removeFromParent();
        if (game.world.children.query<Brick>().isEmpty) {
          game.playState = PlayState.won;
          game.world.removeAll(game.world.children.query<Ball>());
          game.world.removeAll(game.world.children.query<Bat>());
        }
      }
    }
  }
}