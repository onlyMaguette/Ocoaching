import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patient_flutter/common/dashboard_top_bar_title.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:patient_flutter/screen/appointment_screen/widget/appointments.dart';
import 'package:patient_flutter/utils/color_res.dart';

import 'coach.dart';
/*
* import 'email_service.dart'; // Import the email service
  import 'sms_service.dart'; // Import the SMS service
* */

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  // Définir la méthode isAuthenticatedAsCoach dans la classe AppointmentScreen
  Future<bool> isAuthenticatedAsCoach() async {
    try {
      // Récupérer l'utilisateur actuellement authentifié
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Accéder au document de l'utilisateur dans Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Vérifier si le document existe et si le champ "isCoach" est vrai
        if (userDoc.exists &&
            userDoc.data() != null &&
            (userDoc.data() as Map<String, dynamic>)['isCoach'] == true) {
          return true; // L'utilisateur est authentifié en tant que coach
        }
      }

      // L'utilisateur n'est pas authentifié en tant que coach
      return false;
    } catch (e) {
      // Gérer les erreurs éventuelles
      print('Error checking user coach status: $e');
      return false; // Retourner false en cas d'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppointmentScreenController();

    // Définir la variable isCoach en utilisant la fonction isAuthenticatedAsCoach
    Future<bool> isCoach = isAuthenticatedAsCoach();

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
        // Vérifier si l'utilisateur est authentifié et s'il a les autorisations nécessaires
        if (await isAuthenticatedAsCoach()) {
          // Récupérer le dossier client du coach actuellement authentifié
          Client client = await getCurrentCoachClient();

          // Afficher le dossier client du coach actuel
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CoachDossierScreen(client: client);
            },
          );
        } else {
          // Si l'utilisateur n'est pas authentifié ou n'a pas les autorisations nécessaires, afficher un message d'erreur ou rediriger vers la page de connexion
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(S.current.error),
                content: Text(S.current.authenticationError),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text(S.current.ok),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error showing client dossier modal: $e');
        // Handle error
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

    Future<bool> checkAppointmentConflict(
        Coach coach, String date, String time) async {
      try {
        // Query Firestore to check for existing appointments for the coach at the specified date and time
        QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('coachId', isEqualTo: coach.id)
            .where('date', isEqualTo: date)
            .where('time', isEqualTo: time)
            .get();

        // If any appointments found, there is a conflict
        return appointmentsSnapshot.docs.isNotEmpty;
      } catch (e) {
        print('Error checking appointment conflict: $e');
        return true; // Treat error as a conflict to prevent accidental overlapping appointments
      }
    }

    // Function to handle booking appointment and sending confirmation
    void bookAppointment(BuildContext context, Coach selectedCoach) async {
      final appointmentDate = controller.getNextAvailableAppointmentDate();
      final appointmentTime = controller.getNextAvailableAppointmentTime();

      // Convertir les dates de DateTime en String
      final String formattedDate = appointmentDate.toString();
      final String formattedTime = appointmentTime.toString();

      try {
        // Check if appointment slot is available
        bool isConflict = await checkAppointmentConflict(
            selectedCoach, formattedDate, formattedTime);

        if (!isConflict) {
          // Display error message if slot is not available
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(S.current.error),
                content: Text(S.current.appointmentSlotNotAvailable),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text(S.current.ok),
                  ),
                ],
              );
            },
          );
          return;
        }

        // La durée de rendez-vous est fixe à 15 minutes
        Duration appointmentDuration = controller.getAppointmentDuration();
        if (appointmentDuration != Duration(minutes: 15)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(S.current.error),
                content: Text(S.current.appointmentDurationExceedsLimit),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(S.current.ok),
                  ),
                ],
              );
            },
          );
          return;
        }

        // Send confirmation email
        _sendConfirmationEmail(selectedCoach.email, appointmentDate.toString(),
            appointmentTime.toString());

        // Send confirmation SMS
        _sendConfirmationSMS(selectedCoach.phone, appointmentDate.toString(),
            appointmentTime.toString());

        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.current.scheduleSession),
              content: Text(
                '${S.current.successfullyScheduled} ${selectedCoach.name} ${S.current.on} ${S.current.date}: $appointmentDate ${S.current.at} ${S.current.time}: $appointmentTime. ${S.current.confirmationSent}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.current.ok),
                ),
                IconButton(
                  icon: Icon(Icons.folder),
                  onPressed: () {
                    _showClientDossierModal(context);
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error booking appointment: $e');
        // Handle error
      }
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
                      title: Text(S.current.selectCoach),
                      // Remplace 'Select Coach' par S.current.selectCoach
                      content: SingleChildScrollView(
                        child: Column(
                          children: availableCoaches.map((coach) {
                            return ListTile(
                              title: Text(coach.name),
                              // coach.name est déjà une variable dynamique et n'a pas besoin de modification
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
                      title: Text(S.of(context).noAvailableCoaches),
                      content: Text(S.of(context).noCoachesAvailableMessage),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(S.of(context).ok),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text(S.current.scheduleFreeSession),
          ),
          // Ajoutez un bouton ou une icône pour accéder à l'espace dossier client
          FutureBuilder<bool>(
            future: isCoach, // isCoach est un Future<bool>
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Si la connexion est en attente, afficher un indicateur de chargement
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  // Si une erreur s'est produite, afficher un message d'erreur
                  return Text('Error:" ${snapshot.error}');
                } else {
                  // Sinon, utiliser la valeur booléenne pour définir la visibilité
                  return Visibility(
                    visible: snapshot.data ?? false,
                    child: IconButton(
                      icon: Icon(Icons.folder),
                      onPressed: () {
                        _showClientDossierModal(context);
                      },
                    ),
                  );
                }
              }
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
        title: Text(S.current
            .clientDossier), // Utilisation de la localisation pour le titre de l'AppBar
      ),
      body: Center(
        child: Text(S.current
            .clientDossierScreen), // Utilisation de la localisation pour le texte du corps
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
              S.current.clientDossier,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(S.current.clientDossierDetails),
            // Ajoutez les détails du dossier client ici
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fermer la fenêtre modale lorsque le bouton est cliqué
              },
              child: Text(S.current.close),
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
          title: Text(S.current.addNewEntry),
          // Modify here
          // Contenu de la boîte de dialogue pour saisir les détails de la nouvelle entrée
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ajoutez les champs nécessaires pour saisir les détails de la nouvelle entrée, par exemple un champ de texte pour les notes ou les progrès
                TextField(
                  decoration: InputDecoration(
                    labelText: S.current.newEntryDetails, // Modify here
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
              child: Text(S.current.cancel), // Modify here
            ),
            ElevatedButton(
              onPressed: () {
                // Récupérer la valeur saisie dans le champ de texte
                String nouvelleEntree = entryController.text;

                // Vérifier si la valeur saisie n'est pas vide
                if (nouvelleEntree.isNotEmpty) {
                  // Ajouter la nouvelle entrée au dossier client
                  client.addNewEntry(nouvelleEntree);

                  // Optionally, save the client data back to Firestore
                  client.updateClientInFirestore();

                  // Fermer la boîte de dialogue
                  Navigator.of(context).pop();
                } else {
                  // Afficher un message d'erreur si la valeur saisie est vide
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.current.validEntryError), // Modify here
                    ),
                  );
                }
              },
              child: Text(S.current.add), // Modify here
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
        title: Text(
            '${client.firstName} ${client.lastName} - ${S.current.dossier}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${S.current.clientObjectives}:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(S.current.clientObjectives),
            SizedBox(height: 16),
            Text(
              '${S.current.recentProgress}:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(S.current.recentProgress),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _ajouterNouvelleEntree(
                    context); // Call the method to add a new entry to the client's dossier
              },
              child: Text(S.current.addNewEntry),
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
  // Méthode pour ajouter un nouveau client à Firestore
  Future<void> addClientToFirestore() async {
    try {
      // Référence à la collection "clients" dans Firestore
      CollectionReference clientsCollection =
          FirebaseFirestore.instance.collection('clients');

      // Utiliser l'ID de l'utilisateur actuellement authentifié comme ID du document
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ajouter un nouveau document avec l'ID de l'utilisateur
        await clientsCollection.doc(user.uid).set(toMap());
      } else {
        throw Exception('No user authenticated');
      }

      print('Client added successfully!');
    } catch (e) {
      print('Error adding client: $e');
    }
  }

  // Méthode pour mettre à jour les données du client dans Firestore
  Future<void> updateClientInFirestore() async {
    try {
      // Utiliser l'ID de l'utilisateur actuellement authentifié comme ID du document
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Référence au document client dans la collection "clients"
        DocumentReference clientDoc =
            FirebaseFirestore.instance.collection('clients').doc(user.uid);

        // Mettre à jour le document avec les nouvelles données du client
        await clientDoc.update(toMap());
      } else {
        throw Exception('No user authenticated');
      }

      print('Client updated successfully!');
    } catch (e) {
      print('Error updating client: $e');
    }
  }
}
