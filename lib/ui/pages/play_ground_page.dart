import 'dart:typed_data';

import 'package:fidibo_task/controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/const_values.dart';

class PlayGroundPage extends StatelessWidget {
  const PlayGroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<MainController>(MainController(context));

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.amber,
        body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: draggableImage(screenWidth, screenHeight, controller),
        ),
      ),
    );
  }

  draggableImage(width, height, MainController controller) {
    return Stack(
      children: [
        GetBuilder(
          init: controller,
          builder: (c) {
            return AnimatedBuilder(
              animation: c.dxAnimation,
              builder: (context, _) {
                return Positioned(
                  left: c.left,
                  top: c.top,
                  child: GestureDetector(
                    onTap: c.generateNewImage,
                    onPanUpdate: c.panUpdate,
                    onPanEnd: c.panEnd,
                    child: Container(
                      width: squareSize,
                      height: squareSize,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: randomImage(controller),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  randomImage(MainController controller) {
    return GetBuilder(
      id: 'randomImageID',
      init: controller,
      builder: (c) {
        if (c.imageLoading) {
          return loading();
        } else {
          return image(c.imageBytes);
        }
      },
    );
  }

  Widget image(Uint8List imageBytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget loading() {
    return const Padding(
      padding: EdgeInsets.all(squareSize / 3),
      child: CircularProgressIndicator(color: Colors.black45),
    );
  }
}
