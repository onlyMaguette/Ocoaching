import 'dart:io';

class AppointmentDetail {
  String date;
  String time;
  String problem;
  int? type;
  int? patientId;
  List<File>? documents;
  num? serviceAmount;

  AppointmentDetail({
    required this.date,
    required this.time,
    required this.problem,
    this.type,
    this.patientId,
    this.documents,
    this.serviceAmount,
  });
}

class PrescriptionMedical {
  List<AddMedicine>? addMedicine;
  String? notes;

  PrescriptionMedical(this.addMedicine, this.notes);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['notes'] = notes;
    if (addMedicine != null) {
      map['addMedicine'] = addMedicine?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  PrescriptionMedical.fromJson(dynamic json) {
    notes = json['notes'];
    if (json['addMedicine'] != null) {
      addMedicine = [];
      json['addMedicine'].forEach((v) {
        addMedicine?.add(AddMedicine.fromJson(v));
      });
    }
  }
}

class AddMedicine {
  String? title;
  int? quantity;
  String? dosage;
  int? mealTime;
  String? notes;

  // Nouvelles propriétés
  String? name;
  String? schedule;
  String? description;

  AddMedicine({
    this.title,
    this.quantity,
    this.dosage,
    this.mealTime,
    this.notes,
    this.name, // Ajout de la propriété name
    this.schedule,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['quantity'] = quantity;
    map['dosage'] = dosage;
    map['mealTime'] = mealTime;
    map['notes'] = notes;
    // Ajout des nouvelles propriétés
    map['name'] = name;
    map['schedule'] = schedule;
    map['description'] = description;
    return map;
  }

  AddMedicine.fromJson(dynamic json) {
    title = json['title'];
    quantity = json['quantity'];
    dosage = json['dosage'];
    mealTime = json['mealTime'];
    notes = json['notes'];
    // Récupération des nouvelles propriétés
    name = json['name'];
    schedule = json['schedule'];
    description = json['description'];
  }
}
