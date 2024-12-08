import 'dart:math';

import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../blocs/device_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'devices_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late bool _isDarkTheme;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _reloadPage() {
    context.read<DeviceBloc>().add(LoadDevices());
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Room'),
          content: AddRoomForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartHomz'),
        actions: [
          AnimateIcon(
            key: UniqueKey(),
            onTap: () {
              _reloadPage();
            },
            iconType: IconType.continueAnimation,
            height: 70,
            width: 70,
            color: Color.fromRGBO(
              Random.secure().nextInt(255),
              Random.secure().nextInt(200),
              Random.secure().nextInt(255),
              1,
            ),
            animateIcon: AnimateIcons.refresh,
          ),
          AnimateIcon(
            key: UniqueKey(),
            onTap: () {
              _showAddRoomDialog();
            },
            iconType: IconType.animatedOnTap,
            height: 70,
            width: 70,
            color: Color.fromRGBO(
              Random.secure().nextInt(255),
              Random.secure().nextInt(200),
              Random.secure().nextInt(255),
              1,
            ),
            animateIcon: AnimateIcons.add,
          ),
          AnimateIcon(
            key: UniqueKey(),
            onTap: () {
              context.read<AuthBloc>().add(SignOut());
            },
            iconType: IconType.animatedOnTap,
            height: 30,
            width: 30,
            color: Color.fromRGBO(
              Random.secure().nextInt(255),
              Random.secure().nextInt(200),
              Random.secure().nextInt(255),
              1,
            ),
            animateIcon: AnimateIcons.signOut,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.white], // Same gradient as DevicesScreen
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return BlocBuilder<DeviceBloc, DeviceState>(
                  builder: (context, deviceState) {
                    if (deviceState is DeviceInitial) {
                      context.read<DeviceBloc>().add(LoadDevices());
                      return const Center(child: CircularProgressIndicator());
                    } else if (deviceState is DevicesLoaded) {
                      return Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            color: _isDarkTheme ? Colors.black : Colors.white,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: deviceState.rooms.length,
                                    itemBuilder: (context, index) {
                                      final room = deviceState.rooms[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DevicesScreen(roomId: room.id, roomName: room.name),
                                            ),
                                          );
                                        },
                                        child: AnimatedBuilder(
                                          animation: _fadeAnimation,
                                          builder: (context, child) {
                                            return FadeTransition(
                                              opacity: _fadeAnimation,
                                              child: Container(
                                                margin: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(room.imageUrl),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    room.name,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      backgroundColor: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                SmoothPageIndicator(
                                  controller: _pageController,
                                  count: deviceState.rooms.length,
                                  effect: WormEffect(
                                    dotWidth: 12,
                                    dotHeight: 12,
                                    spacing: 8,
                                    radius: 16,
                                    dotColor: Colors.grey,
                                    activeDotColor: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else if (deviceState is DeviceError) {
                      return Center(child: Text('Error: ${deviceState.message}'));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

class AddRoomForm extends StatefulWidget {
  @override
  _AddRoomFormState createState() => _AddRoomFormState();
}

class _AddRoomFormState extends State<AddRoomForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addRoom() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final room = {
          'name': _nameController.text,
          'imageUrl': _imageUrlController.text,
        };
        await FirebaseFirestore.instance.collection('rooms').add(room);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add room: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Room Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a room name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _imageUrlController,
            decoration: InputDecoration(labelText: 'Image URL'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an image URL';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addRoom,
            child: Text('Add Room'),
          ),
        ],
      ),
    );
  }
}
