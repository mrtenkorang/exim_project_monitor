import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final Widget? icon;
  final double? size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? splashColor;
  final bool? hasShadow;
  final bool? isMenuButton;
  final Function? onTap;
  const CircleIconButton(
      {Key? key,
      this.icon,
      this.size = 40.0,
      this.backgroundColor,
      this.borderColor = Colors.transparent,
      this.splashColor,
      this.hasShadow = false,
      this.isMenuButton = false,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: hasShadow!
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 8.0,
                )
              ],
            )
          : const BoxDecoration(),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: borderColor!, width: borderColor?.value == 0 ? 0 : 1)),
          child: InkWell(
            onTap: () =>
                isMenuButton! ? Scaffold.of(context).openDrawer() : onTap!(),
            customBorder: const CircleBorder(
                side: BorderSide(color: Colors.red, width: 10)),
            splashColor: splashColor,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  final Widget icon;
  final Color backgroundColor;
  final Color? borderColor;
  final Function onTap;
  final double? size;
  const RoundedIconButton(
      {Key? key,
      required this.icon,
      required this.backgroundColor,
      this.borderColor,
      this.size,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: backgroundColor,
            // minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color:
                        borderColor != null ? borderColor! : Colors.transparent,
                    style: borderColor != null
                        ? BorderStyle.solid
                        : BorderStyle.none),
                borderRadius: BorderRadius.circular(10)),
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () => onTap(),
          child: Center(child: icon),
        ));
  }
}
