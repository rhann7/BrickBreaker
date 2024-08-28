import 'package:flutter/material.dart';

const brickColors = [
  Color(0xFFFF3A3A),
  Color(0xFFFF7A32),
  Color(0xFFFFEA2C),
  Color(0xFFBDFF30),
  Color(0xFF38FF45),
  Color(0xFF2ED9FF),
  Color(0xFF3239FF),
  Color(0xFFBE33FF),
  Color(0xFFFF38E1),
  Color(0xFFFF3535),
];

const gameWidth = 820.0;
const gameHeight = 1600.0;
const ballRadius = gameWidth * 0.02;
const batWidth = gameWidth *0.2;
const batHeight = ballRadius * 2;
const batStep = gameWidth * 0.05;
const brickGutter = gameWidth * 0.015;
final brickWidth = (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;
const brickHeight = gameHeight * 0.03;
const difficultyModifier = 1.03;