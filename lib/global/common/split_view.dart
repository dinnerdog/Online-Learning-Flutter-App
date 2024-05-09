import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';

class SplitView extends StatefulWidget {
  const SplitView({
    Key? key,
    required this.menu,
    required this.content,
    this.breakpoint = 600,
    this.menuWidth = 270,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  final Widget menu;
  final Widget content;
  final double breakpoint;
  final double menuWidth;
  final Duration animationDuration;

  @override
  State<SplitView> createState() => SplitViewState();
}

class SplitViewState extends State<SplitView> {
  bool isExpanded = true;

  void toggleMenu() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= widget.breakpoint) {
      return BlocConsumer<MenuBloc, MenuState>(
        bloc: context.read<MenuBloc>(),
        buildWhen: (previous, current) => current is !MenuActionState,
        listenWhen: (previous, current) => current is MenuActionState,
        listener: (context, state) {
          
     

          if (state is MenuToggle) {
            toggleMenu();
          }
        },
        builder: (context, state) {
    
          

  

          return Row(
            children: [
              AnimatedContainer(
                onEnd: () =>
                    context.read<MenuBloc>().add(MenuAnimationCompleted(isExpanded: isExpanded)),
                duration: widget.animationDuration,
                width: isExpanded ? widget.menuWidth : 0,
                child: widget.menu,
              ),
              Expanded(
                child: Scaffold(
                  body: widget.content,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Scaffold(
        body: widget.content,
        drawer: SizedBox(
          width: widget.menuWidth,
          child: Drawer(
            child: widget.menu,
          ),
        ),
      );
    }
  }
}
