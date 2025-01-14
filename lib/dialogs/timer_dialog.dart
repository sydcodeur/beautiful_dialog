import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class TimerDialog {
  static void showTimerDialog(BuildContext context,
      {int seconds = 5, Function? onComplete}) {
    int remainingSeconds = seconds;
    Timer? timer;
    bool isPaused = false;
    final player = AudioPlayer();

    void playSound(String source, {Function? onComplete}) async {
      try {
        await player.play(AssetSource(source));
        player.onPlayerComplete.listen((event) {
          if (onComplete != null) {
            onComplete();
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('AudioPlayers Exception: $e');
        }
      }
    }

    void pauseSound() async {
      try {
        await player.pause();
      } catch (e) {
        if (kDebugMode) {
          print('AudioPlayers Exception: $e');
        }
      }
    }

    void resumeSound() async {
      try {
        await player.resume();
      } catch (e) {
        if (kDebugMode) {
          print('AudioPlayers Exception: $e');
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (timer == null) {
              playSound('start_sound.ogg');
              timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (!isPaused) {
                  if (remainingSeconds == 0) {
                    timer.cancel();
                    playSound('end_sound.ogg', onComplete: () {
                      Navigator.of(context).pop();
                      if (onComplete != null) {
                        onComplete();
                      }
                    });
                  } else {
                    setState(() {
                      remainingSeconds--;
                    });
                  }
                }
              });
            }

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 24,
                backgroundColor: Colors.white,
                title: const Row(
                  children: [
                    Icon(Icons.timer, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      "Auto-closing Dialog",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This dialog will close in $remainingSeconds seconds.",
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: remainingSeconds / seconds,
                            backgroundColor: Colors.grey[300],
                            color: Colors.blue,
                            strokeWidth: 8,
                          ),
                        ),
                        Text(
                          "$remainingSeconds",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isPaused = !isPaused;
                        if (isPaused) {
                          pauseSound();
                        } else {
                          resumeSound();
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                    child: Text(isPaused ? "Resume" : "Pause"),
                  ),
                  TextButton(
                    onPressed: () {
                      timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      timer?.cancel();
      player.dispose();
    });
  }
}
