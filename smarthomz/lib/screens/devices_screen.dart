import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/device_bloc.dart';
import '../models/device.dart';
import '../repos/device_repository.dart';

class DevicesScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const DevicesScreen({Key? key, required this.roomId, required this.roomName})
      : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = (_pageController.page ?? 0).round();
      });
    });
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Device'),
          content: AddDeviceForm(roomId: widget.roomId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDeviceDialog,
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => DeviceBloc(DeviceRepository())..add(LoadDevices()),
        child: BlocBuilder<DeviceBloc, DeviceState>(
          builder: (context, state) {
            if (state is DeviceInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              );
            } else if (state is DevicesLoaded) {
              final devices = state.devices.where((device) => device.roomId == widget.roomId).toList();
              if (devices.isEmpty) {
                return Center(
                  child: Text(
                    'No devices found in this room',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue, Colors.white],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        device.name,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        device.type,
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                      Switch(
                                        value: device.status,
                                        onChanged: (value) {
                                          context.read<DeviceBloc>().add(UpdateDevice(device.id, {'status': value}));
                                        },
                                        activeTrackColor: Colors.blue,
                                        activeColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(devices.length, (index) {
                            return Container(
                              width: 10,
                              height: 10,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? Colors.blue : Colors.grey,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is DeviceError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class AddDeviceForm extends StatefulWidget {
  final String roomId;

  const AddDeviceForm({Key? key, required this.roomId}) : super(key: key);

  @override
  _AddDeviceFormState createState() => _AddDeviceFormState();
}

class _AddDeviceFormState extends State<AddDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _status = false;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addDevice() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final device = {
          'name': _nameController.text,
          'type': _typeController.text,
          'imageUrl': _imageUrlController.text,
          'status': _status,
          'roomId': widget.roomId,
        };
        await FirebaseFirestore.instance.collection('devices').add(device);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add device: $e')),
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
            decoration: InputDecoration(labelText: 'Device Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _typeController,
            decoration: InputDecoration(labelText: 'Device Type'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device type';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _imageUrlController,
            decoration: InputDecoration(labelText: 'Image URL'), // Optional if you want to use images
          ),
          SwitchListTile(
            title: Text('Status'),
            value: _status,
            onChanged: (value) {
              setState(() {
                _status = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addDevice,
            child: Text('Add Device'),
          ),
        ],
      ),
    );
  }
}
