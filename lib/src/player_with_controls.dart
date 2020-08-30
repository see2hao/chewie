import 'dart:ui';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/cupertino_controls.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

class PlayerWithControls extends StatefulWidget {

  PlayerWithControls({@required this.controller, Key key}) : super(key: key);

  final ChewieController controller;

  @override
  _PlayerWithControlsState createState() => _PlayerWithControlsState();
}

class _PlayerWithControlsState extends State<PlayerWithControls> {
  bool _isMirror = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(mirrorListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(mirrorListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(PlayerWithControls oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.addListener(mirrorListener);
    }
    super.didUpdateWidget(oldWidget);
  }

  void mirrorListener() {
    if (mounted) {
      setState(() {
        _isMirror = widget.controller.isMirror;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio:
              chewieController.aspectRatio ?? _calculateAspectRatio(context),
          child: _buildPlayerWithControls(chewieController, context),
        ),
      ),
    );
  }

  Container _buildPlayerWithControls(
      ChewieController chewieController, BuildContext context) {
    print(chewieController.isMirror);
    return Container(
      child: Stack(
        children: <Widget>[
          chewieController.placeholder ?? Container(),
          Center(
            child: AspectRatio(
                aspectRatio: chewieController.aspectRatio ??
                    _calculateAspectRatio(context),
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.rotationY(math.pi * (_isMirror == true ? 1 : 2)),
                  child: VideoPlayer(chewieController.videoPlayerController),
                )),
          ),
          chewieController.overlay ?? Container(),
          _buildControls(context, chewieController),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls()
                : CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
