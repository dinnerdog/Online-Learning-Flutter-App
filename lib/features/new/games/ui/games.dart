import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/model/game_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/games/bloc/games_bloc.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';
import 'package:test1/features/new/games/subviews/puzzle/puzzle.dart';
import 'package:test1/features/new/games/subviews/words_juice/words_juice.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';
import 'package:test1/main.dart';

class Games extends StatefulWidget {
  final UserModel user;

  Games({super.key, required this.user});

  @override
  State<Games> createState() => _GamesState();
}

class _GamesState extends State<Games> {
  GamesBloc gamesBloc = GamesBloc();

  @override
  void initState() {
    gamesBloc.add(GamesInitialEvent(userId: widget.user.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: AppBar(
          title: Text('Games'),
          toolbarHeight: 80,
          actions: [
            IconButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all(AppColors.secondaryColor),
                backgroundColor:
                    MaterialStateProperty.all(AppColors.accentColor),
              ),
              onPressed: () {
                BlocProvider.of<MenuBloc>(context).add(MenuToggleEvent());
              },
              icon: Icon(
                Icons.expand_outlined,
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
          automaticallyImplyLeading: false,
          foregroundColor: AppColors.mainColor,
          backgroundColor: AppColors.secondaryColor,
        ),
        body: ListView(children: [
          BlocBuilder<GamesBloc, GamesState>(
            bloc: gamesBloc,
            builder: (context, state) {
              if (state is GameLoadingState) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is GameSucessState) {
                final usersId = state.games.map((e) => e.userId).toList();

                return StreamBuilder(
                    stream: UserRepository().getUsersByIdsStream(usersId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final users = snapshot.data as List<UserModel>;

                        return Stack(
                          children: [
                            CarouselSlider.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index, realIndex) {
                                final user = users[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Column(
                                    children: [
                                      ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    user.avatarUrl!),
                                          ),
                                          title: Text(user.name,
                                              style: TextStyle(
                                                color: AppColors.mainColor,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          subtitle: Text(user.email,
                                              style: TextStyle(
                                                  color: AppColors.mainColor)),
                                          trailing: Icon(
                                            Icons.numbers,
                                            color: AppColors.mainColor,
                                          )),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text('Pink Dodge',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .mainColor)),
                                                Text(
                                                    'Score: ${state.games[index].pinkDodgeScore}',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .mainColor)),
                                              ],
                                            ),
                                            Container(
                                              height: 50,
                                              width: 1,
                                              color: AppColors.mainColor,
                                            ),
                                            Column(
                                              children: [
                                                Text('Puzzle',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .mainColor)),
                                                Text(
                                                    'Score: ${state.games[index].puzzleScore}',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .mainColor)),
                                              ],
                                            ),
                                            Container(
                                              height: 50,
                                              width: 1,
                                              color: AppColors.mainColor,
                                            ),
                                            Column(
                                              children: [
                                                Text('Words Juice',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .mainColor)),
                                                Text(
                                                    'Score: ${state.games[index].wordsJuiceScore}',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .mainColor)),
                                              ],
                                            ),
                                          ])
                                    ],
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 200,
                                aspectRatio: 16 / 9,
                                viewportFraction: 0.8,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                            Positioned(
                                bottom: 10,
                                right: 10,
                                child: IconButton(
                                  onPressed: () {
                                    showGameDialog(context, state.games, users);
                                  },
                                  icon: Icon(
                                    Icons.menu,
                                    color: AppColors.mainColor,
                                  ),
                                )),
                          ],
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    });
              } else {
                return Center(
                  child: Text('Error'),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PinkDodge(
                            user: widget.user,
                          )),
                );
              },
              child: Stack(
                children: [
                  
                  Container(
                    height: 200,
                    width: double.maxFinite,
                    color: Color.fromARGB(255, 106, 143, 216),
                  ),
                  Positioned(
                    right: 199,
                    child: Image.asset('assets/images/games/1 Pink_Monster/Pink_Monster.png',

                    
                      height: 200, width: 200, fit: BoxFit.cover)),
                  ListTile(
                    title: Text('Pink Dodge',
                        style: TextStyle(
                          color: AppColors.mainColor,
                          fontFamily: 'ValMore',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text('Dodge the trees!',
                        style: TextStyle(color: AppColors.mainColor)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Puzzle(
                            user: widget.user,
                          )),
                );
              },
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.maxFinite,
                    color: Color.fromARGB(255, 60, 124, 60),
                  ),

                   Positioned(
                    right: 199,
                    child: Image.asset('assets/images/games/1 Pink_Monster/puzzle.jpg',

                    
                      height: 200, width: 200, fit: BoxFit.cover)),

                  ListTile(
                    title: Text('Puzzle',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'ValMore',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text('Solve the puzzle!',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WordsJuice(
                            user: widget.user,
                          )),
                );
              },
              child: Stack(
                children: [
                  Image.asset('assets/app_images/words_juice.png',
                      height: 200, width: double.maxFinite, fit: BoxFit.cover),
                  ListTile(
                    title: Text('Words Juice',
                        style: TextStyle(
                          color: Colors.purple,
                          fontFamily: 'ValMore',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text(
                        'How good is your vocabulary? Make a word juice and find out!',
                        style: TextStyle(
                          color: Colors.purple,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}

void showGameDialog(
    BuildContext context, List<GameModel> games, List<UserModel> users) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Icon(Icons.games),
        title: Text('Scores of the games'),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final user = users[index];
              return SizedBox(
                
                height: 50,
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(user.avatarUrl!),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(user.name,
                          style: TextStyle(color: AppColors.mainColor),),
                      ],

                    
                    ),

                    Spacer(),

                    Text(
                      'Pink Dodge: ${games[index].pinkDodgeScore}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.mainColor),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Text('Puzzle: ${games[index].puzzleScore}',
                      style: TextStyle(color: AppColors.mainColor),
                        overflow: TextOverflow.ellipsis),
                             SizedBox(
                      width: 30,
                    ),
                    Text(
                        'Words Juice: ${games[index].wordsJuiceScore}',
                          style: TextStyle(color: AppColors.mainColor),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
            itemCount: users.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          )
        ],
      );
    },
  );
}
