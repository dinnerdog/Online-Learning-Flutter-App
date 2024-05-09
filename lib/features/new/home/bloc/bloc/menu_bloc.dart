// menu_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

// 事件
abstract class MenuEvent {}


class MenuAnimationCompleted extends MenuEvent {
    final bool isExpanded;

  MenuAnimationCompleted({required this.isExpanded});
}

class MenuToggleEvent extends MenuEvent {}


// 状态
abstract class MenuState {}

abstract class MenuActionState extends MenuState {}

class MenuToggle extends MenuActionState {}

class MenuExpanded extends MenuState {}

class MenuCollapsed extends MenuState {



}

// Bloc
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuExpanded()) {
    


    on<MenuToggleEvent>((event, emit) {
      emit(MenuToggle());
    });

    on<MenuAnimationCompleted>((event, emit) {
 
      if (event.isExpanded) {
         emit(MenuExpanded());
      } else {
       emit(MenuCollapsed());
        
      }
     
    });
  }
}
