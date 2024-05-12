import 'package:patient_flutter/model/appointment/fetch_appointment.dart';

class Registration {
  Registration({
    bool? status,
    String? message,
    RegistrationData? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  Registration.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data =
        json['data'] != null ? RegistrationData.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  RegistrationData? _data;

  Registration copyWith({
    bool? status,
    String? message,
    RegistrationData? data,
  }) =>
      Registration(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  RegistrationData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class RegistrationData {
  RegistrationData({
    int? id,
    int? isBlock,
    String? identity,
    int? countryCode,
    String? dob,
    int? gender,
    String? fullname,
    String? email,
    String? phoneNumber,
    String? profileImage,
    int? isNotification,
    int? deviceType,
    String? deviceToken,
    int? loginType,
    int? wallet,
    String? favouriteDoctors,
    String? couponsUsed,
    String? createdAt,
    String? updatedAt,
    List<Patient>? patients,
  }) {
    _id = id;
    _isBlock = isBlock;
    _identity = identity;
    _countryCode = countryCode;
    _dob = dob;
    _gender = gender;
    _fullname = fullname;
    _email = email;
    _phoneNumber = phoneNumber;
    _profileImage = profileImage;
    _isNotification = isNotification;
    _deviceType = deviceType;
    _deviceToken = deviceToken;
    _loginType = loginType;
    _wallet = wallet;
    _favouriteDoctors = favouriteDoctors;
    _couponsUsed = couponsUsed;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _patients = patients;
  }

  RegistrationData.fromJson(dynamic json) {
    _id = json['id'];
    _isBlock = json['is_block'];
    _identity = json['identity'];
    _countryCode = json['country_code'];
    _dob = json['dob'];
    _gender = json['gender'];
    _fullname = json['fullname'];
    _email = json['email'];
    _phoneNumber = json['phone_number'];
    _profileImage = json['profile_image'];
    _isNotification = json['is_notification'];
    _deviceType = json['device_type'];
    _deviceToken = json['device_token'];
    _loginType = json['login_type'];
    _wallet = json['wallet'].toInt();
    _favouriteDoctors = json['favourite_doctors'];
    _couponsUsed = json['coupons_used'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    if (json['patients'] != null) {
      _patients = [];
      json['patients'].forEach((v) {
        _patients?.add(Patient.fromJson(v));
      });
    }
  }

  int? _id;
  int? _isBlock;
  String? _identity;
  int? _countryCode;
  String? _dob;
  int? _gender;
  String? _fullname;
  String? _email;
  String? _phoneNumber;
  String? _profileImage;
  int? _isNotification;
  int? _deviceType;
  String? _deviceToken;
  int? _loginType;
  int? _wallet;
  String? _favouriteDoctors;
  String? _couponsUsed;
  String? _createdAt;
  String? _updatedAt;
  List<Patient>? _patients;

  RegistrationData copyWith({
    int? id,
    int? isBlock,
    String? identity,
    int? countryCode,
    String? dob,
    int? gender,
    String? fullname,
    String? email,
    String? phoneNumber,
    String? profileImage,
    int? isNotification,
    int? deviceType,
    String? deviceToken,
    int? loginType,
    int? wallet,
    String? favouriteDoctors,
    String? couponsUsed,
    String? createdAt,
    String? updatedAt,
    List<Patient>? patients,
  }) =>
      RegistrationData(
        id: id ?? _id,
        isBlock: isBlock ?? _isBlock,
        identity: identity ?? _identity,
        countryCode: countryCode ?? _countryCode,
        dob: dob ?? _dob,
        gender: gender ?? _gender,
        fullname: fullname ?? _fullname,
        email: email ?? _email,
        phoneNumber: phoneNumber ?? _phoneNumber,
        profileImage: profileImage ?? _profileImage,
        isNotification: isNotification ?? _isNotification,
        deviceType: deviceType ?? _deviceType,
        deviceToken: deviceToken ?? _deviceToken,
        loginType: loginType ?? _loginType,
        wallet: wallet ?? _wallet,
        favouriteDoctors: favouriteDoctors ?? _favouriteDoctors,
        couponsUsed: couponsUsed ?? _couponsUsed,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        patients: patients ?? _patients,
      );

  int? get id => _id;

  int? get isBlock => _isBlock;

  String? get identity => _identity;

  int? get countryCode => _countryCode;

  String? get dob => _dob;

  int? get gender => _gender;

  String? get fullname => _fullname;

  String? get email => _email;

  String? get phoneNumber => _phoneNumber;

  String? get profileImage => _profileImage;

  int? get isNotification => _isNotification;

  int? get deviceType => _deviceType;

  String? get deviceToken => _deviceToken;

  int? get loginType => _loginType;

  int? get wallet => _wallet;

  String? get favouriteDoctors => _favouriteDoctors;

  String? get couponsUsed => _couponsUsed;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  List<Patient>? get patients => _patients;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['is_block'] = _isBlock;
    map['identity'] = _identity;
    map['country_code'] = _countryCode;
    map['dob'] = _dob;
    map['gender'] = _gender;
    map['fullname'] = _fullname;
    map['email'] = _email;
    map['phone_number'] = _phoneNumber;
    map['profile_image'] = _profileImage;
    map['is_notification'] = _isNotification;
    map['device_type'] = _deviceType;
    map['device_token'] = _deviceToken;
    map['login_type'] = _loginType;
    map['wallet'] = _wallet;
    map['favourite_doctors'] = _favouriteDoctors;
    map['coupons_used'] = _couponsUsed;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_patients != null) {
      map['patients'] = _patients?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
