import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_miarmapp/bloc/user_bloc/user_bloc.dart';
import 'package:flutter_miarmapp/models/user/user_response.dart';
import 'package:flutter_miarmapp/repository/constants.dart';
import 'package:flutter_miarmapp/repository/post_repository/post_repository.dart';
import 'package:flutter_miarmapp/repository/post_repository/post_repository_impl.dart';
import 'package:flutter_miarmapp/repository/user_repository/user_repository.dart';
import 'package:flutter_miarmapp/repository/user_repository/user_repository_impl.dart';
import 'package:flutter_miarmapp/screens/edit_profile_screen.dart';
import 'package:flutter_miarmapp/screens/login_screen.dart';
import 'package:flutter_miarmapp/widgets/error_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  late UserRepository userRepository;

  void navigatorEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    userRepository = UserRepositoryImpl();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return UserBloc(userRepository)..add(FetchUserWithType('Perfil'));
      },
      child: Scaffold(body: _createPopular(context)),
    );
  }

  Widget _createPopular(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserFechedError) {
          return ErrorPage(
            message: state.message,
            retry: () {
              context.watch<UserBloc>().add(FetchUserWithType('Perfil'));
            },
          );
        } else if (state is UserFeched) {
          return _createPopularViewItem(context, state.user);
        } else {
          return const Text('Not support');
        }
      },
    );
  }

  Widget _createPopularViewItem(BuildContext context, UserResponse User) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 100.0,
                    height: 100.0,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      imageUrl: User.avatar.replaceAll(
                          "http://localhost:8080", "http://10.0.2.2:8080"),
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              TextButton(
                                onPressed: null,
                                child: Text(
                                  User.posts.length.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Text("posts"),
                            ],
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  /*Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const FollowPage()));*/
                                },
                                child: Text(
                                  "1.174",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Text(
                                "followers",
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    /*Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const FollowPage()));*/
                                  },
                                  child: Text("832",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                              Text("following"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(User.userName),
                  ),
                ],
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("Flutter Developer"),
                  )
                ],
              ),
              Container(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  width: 320,
                  child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Edit User",
                        style: TextStyle(color: Colors.black),
                      )))

              /* Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 120.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed: () {},
                        child: const Text(
                          "Edit User",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),*/
            ],
          ),
          const Divider(
            height: 10,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.table_chart_outlined)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.person_search)),
                ],
              ),
            ],
          ),
          Flexible(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: User.posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      child: Image(
                    image: NetworkImage(User.posts
                        .elementAt(index)
                        .ficheroMob
                        .toString()
                        .replaceFirst('localhost', '10.0.2.2')),
                    fit: BoxFit.cover,
                  ));
                }),
          ),
        ],
      ),
    );
  }

  Widget _createPost(BuildContext context, Posts postList) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(.3)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                imageUrl: postList.ficheroMob.replaceAll(
                    "http://localhost:8080", "http://10.0.2.2:8080"),
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              postList.titulo,
              style: TextStyle(
                  color: Colors.black.withOpacity(.8),
                  fontWeight: FontWeight.w400,
                  fontSize: 21),
            ),
            trailing: const Icon(Icons.more_vert),
          ),
          CachedNetworkImage(
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            imageUrl: postList.ficheroMob
                .replaceAll("http://localhost:8080", "http://10.0.2.2:8080"),
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: const <Widget>[
                    Icon(Icons.favorite_border, size: 31),
                    SizedBox(
                      width: 12,
                    ),
                    Icon(Icons.comment_sharp, size: 31),
                    SizedBox(
                      width: 12,
                    ),
                    Icon(Icons.send, size: 31),
                  ],
                ),
                const Icon(Icons.bookmark_border, size: 31)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text(
              'liked by you and 385 others',
              style:
                  TextStyle(fontSize: 16, color: Colors.black.withOpacity(.8)),
            ),
          )
        ],
      ),
    );
  }
}
