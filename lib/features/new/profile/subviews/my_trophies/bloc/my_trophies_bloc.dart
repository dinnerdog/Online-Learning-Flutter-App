import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'my_trophies_event.dart';
part 'my_trophies_state.dart';

class MyTrophiesBloc extends Bloc<MyTrophiesEvent, MyTrophiesState> {
  MyTrophiesBloc() : super(MyTrophiesInitial()) {
    on<MyTrophiesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
