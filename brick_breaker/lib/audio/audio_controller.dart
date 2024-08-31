import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  static final Logger _log = Logger('AudioController');

  SoLoud? _soloud;
  SoundHandle? _musicHandle;
  SoundHandle? _alarmHandle;
  double musicVolume = 0.5;
  double alarmVolume = 1;

  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  void dispose() {
    _soloud?.deinit();
  }

  Future<void> playSound(String assetKey) async {
    try {
      final source = await _soloud!.loadAsset(assetKey);
      await _soloud!.play(source);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  Future<void> playLoopingSound(String assetKey) async {
    try {
      if (_alarmHandle != null && _soloud!.getIsValidVoiceHandle(_alarmHandle!)) {
        _log.info('Alarm is already playing.');
        return;
      }

      final source = await _soloud!.loadAsset(assetKey);
      _alarmHandle = await _soloud!.play(source, looping: true);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play looping sound '$assetKey' . Ignoring.", e);
    }
  }

  Future<void> stopAlarm() async {
    if (_alarmHandle != null) {
      _log.info('Stopping alarm sound...');
      try {
        await _soloud!.stop(_alarmHandle!);
      } catch (e) {
        _log.severe('Error stopping alarm sound', e);
      }
      _alarmHandle = null;
      _log.info('Alarm sound stopped.');
    }
  }

  Future<void> startMusic() async {
    if (_musicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
        _log.info('Music is already playing. Stopping first.');
        await _soloud!.stop(_musicHandle!);
      }
    }

    _log.info('Loading music');
    final musicSource = await _soloud!
        .loadAsset('assets/music/looped-song.mp3', mode: LoadMode.disk);
    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _log.info('Music source disposed');
      _musicHandle = null;
    });

     _log.info('Playing music');
    _musicHandle = await _soloud!.play(musicSource, looping: true);
    _soloud!.setVolume(_musicHandle!, musicVolume);
  }

  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void stopMusic() {
    if (_musicHandle != null && _soloud!.getIsValidVoiceHandle(_musicHandle!)) {
      _soloud!.stop(_musicHandle!);
      _log.info('Music stopped.');
    }
  }

  void applyFilter() {
    _soloud!.addGlobalFilter(FilterType.freeverbFilter);
    _soloud!.setFilterParameter(FilterType.freeverbFilter, 0, 0.2);
    _soloud!.setFilterParameter(FilterType.freeverbFilter, 2, 0.9);
  }

  void removeFilter() {
    _soloud!.removeGlobalFilter(FilterType.freeverbFilter);
  }
}