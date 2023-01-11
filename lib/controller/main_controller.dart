import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../const/const_values.dart';

class MainController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final BuildContext context;
  MainController(this.context) {
    initAnimation();
  }

  @override
  void onInit() async {
    await generateNewImage();
    super.onInit();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  // screen size:
  late final double screenWidth = Get.width;
  late final double screenHeigth =
      Get.height - MediaQuery.of(context).padding.top;

  // position values:
  late double left = (screenWidth / 2) - (squareSize / 2);
  late double top = (screenHeigth / 2) - (squareSize / 2);

  late double startLeft = left;
  late double startTop = top;
  late double startDx = 0;
  late double startDy = 0;

  int dxSign = 1;
  int dySign = 1;

  void resetValue() {
    if (animationController.isAnimating) {
      animationController.stop();
    }
    dxSign = 1;
    dySign = 1;
    startDx = 0;
    startDy = 0;
    startLeft = left;
    startTop = top;
  }

  // animation values:
  late Duration dxDuration;
  late AnimationController animationController;
  late Animation<double> dxAnimation;
  late Animation<double> dyAnimation;

  initAnimation() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    dxAnimation =
        Tween<double>(begin: 0, end: 2000).animate(animationController);
  }

  panEnd(DragEndDetails dd) {
    startLeft = left;
    startTop = top;

    final maxDuration = max(dd.velocity.pixelsPerSecond.dy ~/ 24,
        dd.velocity.pixelsPerSecond.dx ~/ 24);

    dxDuration = Duration(milliseconds: max(24, maxDuration) * 100);
    animationController.duration = dxDuration;
    dxAnimation = Tween<double>(begin: 0, end: dd.velocity.pixelsPerSecond.dx)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));
    dyAnimation = Tween<double>(begin: 0, end: dd.velocity.pixelsPerSecond.dy)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));

    dxAnimation.addListener(() {
      calculateLeft();
    });
    dyAnimation.addListener(() {
      calculateTop();
    });

    animationController.reset();
    animationController.forward();
  }

  void calculateLeft() {
    if (startLeft + (dxSign * (dxAnimation.value - startDx)) >=
        screenWidth - squareSize) {
      dxSign = -1 * dxSign;
      startLeft = screenWidth - squareSize;
      startDx = dxAnimation.value;
      left = startLeft + (dxSign * (dxAnimation.value - startDx));
    } else if (startLeft + (dxSign * (dxAnimation.value - startDx)) <= 0) {
      dxSign = -1 * dxSign;
      startLeft = 0;
      startDx = dxAnimation.value;
      left = startLeft + (dxSign * (dxAnimation.value - startDx));
    } else {
      left = startLeft + (dxSign * (dxAnimation.value - startDx));
    }
  }

  void calculateTop() {
    if (startTop + (dySign * (dyAnimation.value - startDy)) >=
        screenHeigth - squareSize) {
      dySign = -1 * dySign;
      startTop = screenHeigth - squareSize;
      startDy = dyAnimation.value;
    }
    if (startTop + (dySign * (dyAnimation.value - startDy)) <= 0) {
      dySign = -1 * dySign;
      startTop = 0;
      startDy = dyAnimation.value;
    }
    top = startTop + (dySign * (dyAnimation.value - startDy));
  }

  panUpdate(DragUpdateDetails dd) {
    resetValue();
    left = max(0, min(screenWidth - squareSize, left + dd.delta.dx));
    top = max(0, min(screenHeigth - squareSize, top + dd.delta.dy));
    update();
  }

  // image values:
  late Uint8List imageBytes;
  bool imageLoading = false;

  Future<void> generateNewImage() async {
    imageLoading = true;
    update(['randomImageID']);
    await NetworkAssetBundle(Uri.parse(url)).load(url).then(
      (value) {
        imageBytes = value.buffer.asUint8List();
        imageLoading = false;
        update(['randomImageID']);
      },
    );
  }
}
