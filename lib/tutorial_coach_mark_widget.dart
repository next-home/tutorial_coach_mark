import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/util.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus target, bool goingForward) clickTarget;
  final Function() finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final Function() clickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;

  const TutorialCoachMarkWidget(
      {Key key,
      this.targets,
      this.finish,
      this.paddingFocus = 10,
      this.clickTarget,
      this.alignSkip = Alignment.topRight,
      this.textSkip = "SKIP",
      this.clickSkip,
      this.colorShadow = Colors.black,
      this.opacityShadow = 0.8,
      this.textStyleSkip = const TextStyle(color: Colors.white),
      this.hideSkip})
      : super(key: key);

  @override
  _TutorialCoachMarkWidgetState createState() =>
      _TutorialCoachMarkWidgetState();
}

class _TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget> {
  StreamController _controllerFade = StreamController<double>.broadcast();
  StreamController _controllerTapChild = StreamController<void>.broadcast();
  StreamController _controllerTapPrevious = StreamController<void>.broadcast();
  StreamController _controllerTapNext = StreamController<void>.broadcast();

  TargetFocus currentTarget;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            clickTarget: (target, goingForward) {
              if (widget.clickTarget != null)
                widget.clickTarget(target, goingForward);
            },
            focus: (target) {
              currentTarget = target;
              _controllerFade.sink.add(1.0);
            },
            removeFocus: () {
              _controllerFade.sink.add(0.0);
            },
            streamTap: _controllerTapChild.stream,
            streamTapPrevious: _controllerTapPrevious.stream,
            streamTapNext: _controllerTapNext.stream,
          ),
          _buildContents(),
          _buildSkip()
        ],
      ),
    );
  }

  _buildContents() {
    return StreamBuilder(
      stream: _controllerFade.stream,
      initialData: 0.0,
      builder: (_, snapshot) {
        try {
          return AnimatedOpacity(
            opacity: snapshot.data,
            duration: Duration(milliseconds: 300),
            child: _buildPositionedsContents(),
          );
        } catch (err) {
          return Container();
        }
      },
    );
  }

  _buildPositionedsContents() {
    if (currentTarget == null) {
      return Container();
    }

    List<Widget> widgtes = List();

    TargetPosition target = getTargetCurrent(currentTarget);
    var positioned = Offset(target.offset.dx + target.size.width / 2,
        target.offset.dy + target.size.height / 2);
    double haloWidth;
    double haloHeight;
    if (currentTarget.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height
          ? target.size.width
          : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }
    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;
    double weight = 0.0;

    double top;
    double bottom;
    double left;

    widgtes = currentTarget.contents.map<Widget>((i) {
      switch (i.align) {
        case AlignContent.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight +
                (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case AlignContent.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        child: GestureDetector(
          onTap: () {
            // _controllerTapChild.add(null);
          },
          child: Container(
            width: weight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  i.child,
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: SizedBox(
                      width: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //Center Row contents horizontally,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, //Center Row contents vertically,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                _controllerTapPrevious.add(null);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Text(
                                    "Previous",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                _controllerTapNext.add(null);
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Text(
                                    "Next",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                    // style: labelText.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: widgtes,
    );
  }

  _buildSkip() {
    if (widget.hideSkip) {
      return Container();
    }
    return Align(
      alignment: widget.alignSkip,
      child: SafeArea(
        child: StreamBuilder(
          stream: _controllerFade.stream,
          initialData: 0.0,
          builder: (_, snapshot) {
            return AnimatedOpacity(
              opacity: snapshot.data,
              duration: Duration(milliseconds: 300),
              child: InkWell(
                onTap: () {
                  widget.finish();
                  if (widget.clickSkip != null) {
                    widget.clickSkip();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    widget.textSkip,
                    style: widget.textStyleSkip,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerFade.close();
    super.dispose();
  }
}
