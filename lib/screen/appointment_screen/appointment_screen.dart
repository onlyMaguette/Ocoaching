import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:patient_flutter/common/dashboard_top_bar_title.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:patient_flutter/screen/appointment_screen/widget/appointments.dart';
import 'package:patient_flutter/utils/color_res.dart';

import 'coach.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = AppointmentScreenController();

    // Définir la méthode isAuthenticatedAsCoach dans la classe AppointmentScreen
    Future<bool> isAuthenticatedAsCoach() async {
      try {
        // Récupérer le token Firebase de l'utilisateur
        final String? deviceToken = await FirebaseMessaging.instance.getToken();

        // Vérifier si le token Firebase est présent
        return deviceToken != null && deviceToken.isNotEmpty;
      } catch (e) {
        // Gérer les erreurs éventuelles
        print('Error getting Firebase token: $e');
        return false; // Retourner false en cas d'erreur
      }
    }

    Future<Client> getCurrentCoachClient() async {
      try {
        // Récupérer l'utilisateur actuellement authentifié
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Utiliser l'ID utilisateur pour rechercher dans Firestore le dossier client associé
          DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
              .collection('clients')
              .doc(user.uid)
              .get();

          // Vérifier si le dossier client existe
          if (clientSnapshot.exists) {
            // Récupérer les données du dossier client à partir du snapshot
            Map<String, dynamic> clientData =
                clientSnapshot.data() as Map<String, dynamic>;

            // Créer un objet Client à partir des données récupérées
            return Client(
              firstName: clientData['firstName'],
              lastName: clientData['lastName'],
              goals: clientData['goals'],
              recentProgress: clientData['recentProgress'],
            );
          } else {
            // Si le dossier client n'existe pas, retourner une erreur ou gérer selon les besoins
            throw Exception('Client dossier not found');
          }
        } else {
          // Si aucun utilisateur n'est authentifié, retourner une erreur ou gérer selon les besoins
          throw Exception('No user authenticated');
        }
      } catch (e) {
        // Gérer les erreurs éventuelles
        print('Error getting current coach client: $e');
        throw Exception('Error getting current coach client: $e');
      }
    }

    void _showClientDossierModal(BuildContext context) async {
      try {
        // Récupérer le dossier client du coach actuellement authentifié
        Client client = await getCurrentCoachClient();

        // Afficher le dossier client du coach actuel
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CoachDossierScreen(client: client);
          },
        );
      } catch (e) {
        // Gérer les erreurs éventuelles
        print('Error showing client dossier modal: $e');
      }
    }

    // Function to send confirmation email
    void _sendConfirmationEmail(String email, String date, String time) {
      // Implement code to send email confirmation
      // This could involve using a third-party email service or your own server
      // For demonstration purposes, we'll just print the email content
      print('Email confirmation sent to $email for $date at $time');
    }

    // Function to send confirmation SMS
    void _sendConfirmationSMS(String phone, String date, String time) {
      // Implement code to send SMS confirmation
      // This could involve using a third-party SMS service or your own server
      // For demonstration purposes, we'll just print the SMS content
      print('SMS confirmation sent to $phone for $date at $time');
    }

    // Function to handle booking appointment and sending confirmation
    void bookAppointment(BuildContext context, Coach selectedCoach) {
      final appointmentDate =
          controller.getNextAvailableAppointmentDate().toString();
      final appointmentTime =
          controller.getNextAvailableAppointmentTime().toString();

      // Send confirmation email
      _sendConfirmationEmail(
          selectedCoach.email, appointmentDate, appointmentTime);

      // Send confirmation SMS
      _sendConfirmationSMS(
          selectedCoach.phone, appointmentDate, appointmentTime);

      // Here you would implement the code to actually book the appointment,
      // which could involve making API calls or updating database records.
      // For demonstration purposes, let's just display an alert dialog.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Book Appointment'),
            content: Text(
                'You have successfully booked a 15-minute free appointment with ${selectedCoach.name} on $appointmentDate at $appointmentTime. Confirmation has been sent.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
              // Bouton ou icône pour accéder à l'espace dossier client
              IconButton(
                icon: Icon(Icons.folder),
                onPressed: () {
                  // Afficher la fenêtre modale du dossier client lorsqu'on clique sur le bouton ou l'icône
                  _showClientDossierModal(context);
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          DashboardTopBarTitle(title: S.current.appointments),
          Appointments(controller: controller),
          ElevatedButton(
            onPressed: () {
              // Obtenir la liste des coaches disponibles
              final List<Coach> availableCoaches =
                  controller.getAvailableCoaches();

              // Vérifier s'il y a des coaches disponibles
              if (availableCoaches.isNotEmpty) {
                // Afficher une boîte de dialogue pour sélectionner un coach
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Coach'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: availableCoaches.map((coach) {
                            return ListTile(
                              title: Text(coach.name),
                              onTap: () {
                                // Fermer la boîte de dialogue
                                Navigator.pop(context);

                                // Réserver un rendez-vous avec le coach sélectionné
                                bookAppointment(context, coach);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Si aucun coach n'est disponible, afficher un message
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('No Available Coaches'),
                      content: Text(
                          'Sorry, there are currently no coaches available for booking. Please try again later.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text('Book a Free Appointment'),
          ),
          // Ajoutez un bouton ou une icône pour accéder à l'espace dossier client
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: () {
              // Afficher la fenêtre modale du dossier client
              _showClientDossierModal(context);
            },
          ),
        ],
      ),
    );
  }
}

// Placeholder for client dossier screen
class ClientDossierScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add authentication/authorization logic here if needed
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Dossier'),
      ),
      body: Center(
        child: Text('Client Dossier Screen'),
      ),
    );
  }
}

// Classe pour afficher la fenêtre modale des détails du dossier client
class ClientDossierDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Client Dossier',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Client Dossier Details'),
            // Ajoutez les détails du dossier client ici
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fermer la fenêtre modale lorsque le bouton est cliqué
              },
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachDossierScreen extends StatelessWidget {
  final Client client;
  final TextEditingController entryController =
      TextEditingController(); // Déclaration de entryController

  CoachDossierScreen({required this.client});

  // Méthode pour gérer l'ajout d'une nouvelle entrée au dossier client
  void _ajouterNouvelleEntree(BuildContext context) {
    // Implémentez ici la logique pour ajouter une nouvelle entrée au dossier client
    // Cela peut inclure l'ouverture d'une boîte de dialogue ou la navigation vers une autre page pour saisir les détails de la nouvelle entrée.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new entry'),
          // Contenu de la boîte de dialogue pour saisir les détails de la nouvelle entrée
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ajoutez les champs nécessaires pour saisir les détails de la nouvelle entrée, par exemple un champ de texte pour les notes ou les progrès
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Add a new entry',
                  ),
                  // Vous pouvez utiliser un TextEditingController pour récupérer la valeur saisie par l'utilisateur
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Récupérer la valeur saisie dans le champ de texte
                String nouvelleEntree = entryController.text;

                // Vérifier si la valeur saisie n'est pas vide
                if (nouvelleEntree.isNotEmpty) {
                  // Ajouter la nouvelle entrée au dossier client
                  client.addNewEntry(nouvelleEntree);

                  // Fermer la boîte de dialogue
                  Navigator.of(context).pop();
                } else {
                  // Afficher un message d'erreur si la valeur saisie est vide
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid entry.'),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${client.firstName} ${client.lastName} - Dossier'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objectifs du client:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(client.goals),
            SizedBox(height: 16),
            Text(
              'Progrès récents:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(client.recentProgress),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _ajouterNouvelleEntree(
                    context); // Appeler la méthode pour ajouter une nouvelle entrée au dossier client
              },
              child: Text('Ajouter une entrée'),
            ),
          ],
        ),
      ),
    );
  }
}

class Client {
  final String firstName;
  final String lastName;
  final String goals;
  final String recentProgress;
  List<String> entries = []; // List to store client entries

  Client({
    required this.firstName,
    required this.lastName,
    required this.goals,
    required this.recentProgress,
  });

  // Method to add a new entry to the client dossier
  void addNewEntry(String entry) {
    entries.add(entry); // Add the new entry to the list
  }

  // Convertir un client en Map pour l'ajouter à Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'goals': goals,
      'recentProgress': recentProgress,
      'entries': entries,
    };
  }

  // Méthode pour ajouter un nouveau client à Firestore
  Future<void> addClientToFirestore() async {
    try {
      // Référence à la collection "clients" dans Firestore
      CollectionReference clientsCollection =
          FirebaseFirestore.instance.collection('clients');

      // Ajouter un nouveau document avec un ID généré automatiquement
      await clientsCollection.add(toMap());

      print('Client added successfully!');
    } catch (e) {
      print('Error adding client: $e');
    }
  }
}
