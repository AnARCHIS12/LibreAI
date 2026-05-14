<p align="center">
  <img src="assets/logo.png" width="96" alt="Libre AI logo">
</p>

<h1 align="center">Libre AI</h1>

<p align="center">
  <a href="https://github.com/AnARCHIS12/LibreAI"><img alt="GitHub" src="https://img.shields.io/badge/GitHub-LibreAI-15151B?logo=github"></a>
  <a href="https://anarchis12.github.io/LibreAI/"><img alt="Site" src="https://img.shields.io/badge/Site-GitHub%20Pages-16C7C7"></a>
  <a href="https://github.com/AnARCHIS12/LibreAI/releases/latest/download/libre-ai.apk"><img alt="APK" src="https://img.shields.io/badge/APK-download-FF5A3D"></a>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Android-02569B?logo=flutter&logoColor=white">
  <img alt="Mistral API" src="https://img.shields.io/badge/Mistral-API-FF5A3D">
  <img alt="Local memory" src="https://img.shields.io/badge/Memory-local-16C7C7">
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-lightgrey"></a>
</p>

<p align="center">
  <a href="https://anarchis12.github.io/LibreAI/">Site web</a>
  ·
  <a href="https://github.com/AnARCHIS12/LibreAI/releases/latest/download/libre-ai.apk">Telecharger l'APK</a>
  ·
  <a href="https://github.com/AnARCHIS12/LibreAI/releases">Releases</a>
</p>

Libre AI est une application Android Flutter qui utilise l'API Mistral avec une interface de chat, une memoire locale, un historique de conversations, des outils IA et une configuration locale de la cle API.

Le projet vise une application simple a installer, sans backend personnel ajoute. La cle API, les conversations, la memoire et les preferences sont stockees localement sur l'appareil.

## Fonctionnalites

- Chat avec les modeles Mistral.
- Copie des reponses IA comme dans ChatGPT.
- Recuperation de la liste des modeles depuis `GET /v1/models`.
- Selection du modele depuis les parametres.
- Sauvegarde locale securisee de la cle API.
- Lien direct vers la page officielle Mistral pour creer une cle API.
- Historique local des conversations.
- Memoire adaptative locale, mise a jour automatiquement avec Mistral.
- Dictee vocale Android.
- Recherche web avec affichage des sources.
- Generation d'images via les outils Mistral.
- Telechargement des images generees.
- OCR de PDF, images et fichiers compatibles.
- Transcription audio avec Voxtral.
- Choix de langue dans les parametres.
- Themes clair, sombre ou systeme.
- Pages separees pour le chat, la bibliotheque et les outils.

## Confidentialite

Les donnees suivantes sont conservees localement sur l'appareil :

- cle API Mistral ;
- historique des conversations ;
- memoire locale ;
- modele selectionne ;
- langue ;
- theme ;
- images generees sauvegardees par l'application.

L'application n'ajoute pas de backend intermediaire. Les appels partent directement de l'application vers l'API Mistral.

Certaines actions envoient des donnees a Mistral :

- les messages de chat ;
- la memoire locale lorsqu'elle sert de contexte ;
- les fichiers envoyes pour OCR ;
- les fichiers audio envoyes pour transcription ;
- les prompts utilises pour generer des images ;
- les messages recents utilises pour mettre a jour la memoire adaptative.

## Cle API Mistral

La cle API peut etre creee depuis la page officielle :

https://console.mistral.ai/api-keys

Dans l'application :

1. Ouvrir les parametres.
2. Coller la cle dans le champ `Cle API Mistral`.
3. Appuyer sur `Enregistrer`.
4. Utiliser `Recuperer les modeles Mistral` pour charger les modeles disponibles.

## Installation

Prerequis :

- Flutter installe ;
- Android SDK configure ;
- un appareil Android ou un emulateur ;
- une cle API Mistral.

Installer les dependances :

```sh
flutter pub get
```

Lancer en debug :

```sh
flutter run
```

Construire un APK debug :

```sh
flutter build apk --debug
```

L'APK est genere dans :

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Configuration par dart-define

Il est aussi possible de fournir une cle ou un modele au lancement :

```sh
flutter run --dart-define=MISTRAL_API_KEY=ta_cle_mistral
```

```sh
flutter run --dart-define=MISTRAL_MODEL=mistral-small-latest
```

Si une cle est fournie par `MISTRAL_API_KEY`, elle est sauvegardee localement au premier demarrage.

## Tests et verification

Commandes utilisees pour verifier le projet :

```sh
flutter analyze
flutter test
flutter build apk --debug
```

## Structure

```text
lib/main.dart
android/app/src/main/AndroidManifest.xml
android/app/src/main/res/drawable/ic_launcher.xml
pubspec.yaml
test/widget_test.dart
```

Le code principal se trouve actuellement dans `lib/main.dart`.
