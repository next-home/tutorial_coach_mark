import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/light_paint.dart';
import 'package:tutorial_coach_mark/light_paint_rect.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/util.dart';

enum ShapeLightFocus { Circle, RRect }

class AnimatedFocusLight extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus) focus;
  final Function(TargetFocus target, bool goingForward) clickTarget;
  final Function removeFocus;
  final Function() finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;
  final Stream<void> streamTap;
  final Stream<void> streamTapPrevious;
  final Stream<void> streamTapNext;

  const AnimatedFocusLight({
    Key key,
    this.targets,
    this.focus,
    this.finish,
    this.removeFocus,
    this.clickTarget,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.streamTap,
    this.streamTapPrevious,
    this.streamTapNext,
  }) : super(key: key);

  @override
  _AnimatedFocusLightState createState() => _AnimatedFocusLightState();
}

class _AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _controllerPulse;
  CurvedAnimation _curvedAnimation;
  Animation tweenPulse;
  Offset positioned = Offset(0.0, 0.0);
  TargetPosition targetPosition;

  double sizeCircle = 100;
  int currentFocus = -1;
  bool finishFocus = false;
  bool initReverse = false;
  double progressAnimated = 0;

  bool goingForward = true;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            finishFocus = true;
          });
          if (currentFocus >= 0) {
            widget?.focus(widget.targets[currentFocus]);
            _controllerPulse.forward();
          }
        }
        if (status == AnimationStatus.dismissed) {
          setState(() {
            finishFocus = false;
            initReverse = false;
          });
          _nextFocus();
        }

        if (status == AnimationStatus.reverse) {
          widget?.removeFocus();
        }
      });

    _curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.ease);

    _controllerPulse =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _controllerPulse.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controllerPulse.reverse();
      }

      if (status == AnimationStatus.dismissed) {
        if (initReverse) {
          setState(() {
            finishFocus = false;
          });
          _controller.reverse();
        } else if (finishFocus) {
          _controllerPulse.forward();
        }
      }
    });

    tweenPulse = Tween(begin: 1.0, end: 0.99)
        .animate(CurvedAnimation(parent: _controllerPulse, curve: Curves.ease));

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    widget.streamTap.listen((_) {
      _tapHandler();
    });
    widget.streamTapPrevious.listen((_) {
      prevTutorial();
    });
    widget.streamTapNext.listen((_) {
      nextTutorial();
    });
    super.initState();
  }

  void prevTutorial() {
    print('prevTutorial');
    goingForward = false;
    _tapHandler();
  }

  void nextTutorial() {
    print('nextTutorial');
    goingForward = true;
    _tapHandler();
  }

  TextStyle navigationStyle = TextStyle(color: Colors.white, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // _tapHandler();
        },
        child: AnimatedBuilder(
            animation: _controller,
            builder: (_, chuild) {
              progressAnimated = _curvedAnimation.value;
              return AnimatedBuilder(
                animation: _controllerPulse,
                builder: (_, child) {
                  if (finishFocus) {
                    progressAnimated = tweenPulse.value;
                  }
                  return Stack(
                    children: <Widget>[
                      Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: currentFocus != -1
                            ? CustomPaint(
                                painter: widget?.targets[currentFocus]?.shape ==
                                        ShapeLightFocus.RRect
                                    ? LightPaintRect(
                                        colorShadow: widget.colorShadow,
                                        positioned: positioned,
                                        progress: progressAnimated,
                                        offset: widget.paddingFocus,
                                        target: targetPosition,
                                        radius: 15,
                                        opacityShadow: widget.opacityShadow,
                                      )
                                    : LightPaint(
                                        progressAnimated,
                                        positioned,
                                        sizeCircle,
                                        colorShadow: widget.colorShadow,
                                        opacityShadow: widget.opacityShadow,
                                      ),
                              )
                            : Container(),
                      ),
                      // Align(
                      //   alignment: Alignment.bottomRight,
                      //   child: InkWell(
                      //     onTap: () {
                      //       goingForward = true;
                      //       _tapHandler();
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(20.0),
                      //       child: Text(
                      //         currentFocus == widget.targets.length - 1
                      //             ? "Finish"
                      //             : "Next",
                      //         style: navigationStyle,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      /*Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Text(
                                  "(" +
                                      (currentFocus + 1).toString() +
                                      "/" +
                                      widget.targets.length.toString() +
                                      ")",
                                  style:  TextStyle(color: Colors.white, fontSize: 22)))),*/
                      // currentFocus > 0
                      //     ? Align(
                      //   alignment: Alignment.bottomLeft,
                      //   child: InkWell(
                      //     onTap: () {
                      //       print("previous");
                      //       // _tapHandlerPrevious();
                      //       goingForward = false;
                      //       _tapHandler();
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(20.0),
                      //       child: Text(
                      //         "Previous",
                      //         style: navigationStyle,
                      //       ),
                      //     ),
                      //   ),
                      // )
                      //     : Container()
                    ],
                  );
                },
              );
            }),
      ),
    );
  }

  void _tapHandler() {
    if (currentFocus > -1 && initReverse == false && finishFocus == true) {
      setState(() {
        initReverse = true;
        _controllerPulse.reverse(from: _controllerPulse.value);
      });
      if (currentFocus > -1) {
        widget?.clickTarget(widget.targets[currentFocus], goingForward);
      }
    }
  }

  void _nextFocus() {
    if (currentFocus >= widget.targets.length - 1 && goingForward == true) {
      this._finish();
      return;
    }

    if (goingForward == true) {
      currentFocus++;
    } else {
      currentFocus--;
    }

    var targetPosition = getTargetCurrent(widget.targets[currentFocus]);
    if (targetPosition == null && goingForward == true) {
      this._finish();
      return;
    }

    setState(() {
      finishFocus = false;
      this.targetPosition = targetPosition;

      positioned = Offset(
        targetPosition.offset.dx + (targetPosition.size.width / 2),
        targetPosition.offset.dy + (targetPosition.size.height / 2),
      );

      if (targetPosition.size.height > targetPosition.size.width) {
        sizeCircle = targetPosition.size.height * 0.6 + widget.paddingFocus;
      } else {
        sizeCircle = targetPosition.size.width * 0.6 + widget.paddingFocus;
      }
    });

    _controller.forward();
  }

  void _finish() {
    setState(() {
      currentFocus = -1;
    });

    widget.finish();
  }

  @override
  void dispose() {
    _controllerPulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _afterLayout(Duration timeStamp) {
    _nextFocus();
  }
}
