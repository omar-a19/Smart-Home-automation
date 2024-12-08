import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/device.dart';
import '../models/room.dart';
import '../repos/device_repository.dart';

abstract class DeviceEvent {}

class LoadDevices extends DeviceEvent {}

class LoadDevicesForRoom extends DeviceEvent {
  final String roomId;

  LoadDevicesForRoom(this.roomId);
}

class UpdateDevice extends DeviceEvent {
  final String deviceId;
  final Map<String, dynamic> updates;

  UpdateDevice(this.deviceId, this.updates);
}

abstract class DeviceState {}

class DeviceInitial extends DeviceState {}

class DevicesLoaded extends DeviceState {
  final List<Device> devices;
  final List<Room> rooms;

  DevicesLoaded(this.devices, this.rooms);
}

class DevicesForRoomLoaded extends DeviceState {
  final List<Device> devices;

  DevicesForRoomLoaded(this.devices);
}

class DeviceError extends DeviceState {
  final String message;

  DeviceError(this.message);
}

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository _deviceRepository;

  DeviceBloc(this._deviceRepository) : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<LoadDevicesForRoom>(_onLoadDevicesForRoom);
    on<UpdateDevice>(_onUpdateDevice);
  }

  void _onLoadDevices(LoadDevices event, Emitter<DeviceState> emit) async {
    try {
      List<Device> devices = await _deviceRepository.getDevices();
      List<Room> rooms = await _deviceRepository.getRooms();
      emit(DevicesLoaded(devices, rooms));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  void _onLoadDevicesForRoom(LoadDevicesForRoom event, Emitter<DeviceState> emit) async {
    try {
      List<Device> devices = await _deviceRepository.getDevicesByRoom(event.roomId);
      emit(DevicesForRoomLoaded(devices));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onUpdateDevice(UpdateDevice event, Emitter<DeviceState> emit) async {
    try {
      await _deviceRepository.updateDevice(event.deviceId, event.updates);
      List<Device> devices = await _deviceRepository.getDevices();
      emit(DevicesLoaded(devices, []));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }
}
