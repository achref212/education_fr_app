# DELFy — Application mobile

Application Flutter pour les **élèves** de la plateforme Education FR. DELFy permet d’apprendre le français à travers des leçons, quiz, histoires et activités multijoueur, connectée à l’API FastAPI [`education_fr_api`](../education_fr_api).

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean-green)

> Design inspiré du kit Figma [Speaker — Language Learning App](https://www.figma.com/design/IsusRPggUKeUiOTIv7vbgG/Speaker-%E2%80%94-Language-Learning-App-%7C-Mobile-UI-Kit--Community-?node-id=137-4099&m=dev).

---

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Démarrage rapide](#démarrage-rapide)
- [Configuration API](#configuration-api)
- [Génération de code](#génération-de-code)
- [Structure du projet](#structure-du-projet)
- [Navigation & écrans](#navigation--écrans)
- [Intégration backend](#intégration-backend)
- [Thème & assets](#thème--assets)
- [Build & déploiement](#build--déploiement)
- [Dépannage](#dépannage)
- [Projets liés](#projets-liés)

---

## Fonctionnalités

### Implémenté

| Domaine | Description |
|---------|-------------|
| **Splash** | Animation de démarrage + vérification de session JWT |
| **Onboarding** | 3 écrans style « story Instagram » (progression, tap gauche/droite, skip) |
| **Welcome** | Écran d’accueil avec bascule thème clair/sombre |
| **Authentification** | Inscription, connexion, déconnexion (JWT sécurisé) |
| **Navigation principale** | Bottom bar : Accueil, Classement, Profil |
| **Accueil** | Dashboard élève (objectif du jour, catégories, activités, progression) |
| **Profil** | Paramètres thème + déconnexion |
| **Thème** | Light / Dark / System, persistant via `SharedPreferences` |
| **Progression (service)** | Couche domaine + data connectée à `/progress` (cache local) |

### En cours / à venir

| Domaine | Statut |
|---------|--------|
| Leçons (écran détail) | UI home prête, écrans leçon à implémenter |
| Quiz | Carte UI sur l’accueil |
| Histoires (Story) | Carte UI sur l’accueil |
| Multijoueur | Carte UI sur l’accueil |
| Classement | Écran placeholder « Bientôt disponible » |

---

## Stack technique

| Couche | Package |
|--------|---------|
| Framework | Flutter 3.x |
| State management | `flutter_bloc` (Cubit) |
| Navigation | `auto_route` |
| HTTP | `dio` + intercepteurs JWT / erreurs |
| DI | `get_it` |
| Modèles immuables | `freezed` + `json_serializable` |
| Erreurs fonctionnelles | `dartz` (`Either<Failure, T>`) |
| Stockage sécurisé | `flutter_secure_storage` (JWT) |
| Cache local | `shared_preferences` (thème, progression) |
| Animations | `flutter_animate` |
| SVG | `flutter_svg` |
| Icônes app | `flutter_launcher_icons` |

---

## Architecture

Organisation **feature-first** avec **Clean Architecture** :

```
lib/
├── core/
│   ├── error/              # Failures (Server, Network, Auth, Cache…)
│   ├── network/            # Dio, intercepteurs, ApiConstants
│   ├── presentation/       # Widgets réutilisables (AppButton, AppTextField…)
│   ├── router/             # AutoRoute (app_router.dart)
│   ├── storage/            # SecureTokenStorage
│   ├── theme/              # AppColors, AppTextStyles, AppTheme
│   └── usecase/            # UseCase<T, P> abstrait
├── features/
│   ├── auth/               # Domain → Data → Presentation
│   ├── progress/
│   ├── theme/
│   ├── splash/
│   ├── onboarding/
│   ├── home/
│   ├── main/
│   ├── leaderboard/
│   └── profile/
├── injection/
│   └── injection_container.dart   # GetIt
└── main.dart
```

Chaque feature suit le pattern :

```
feature/
├── domain/       entities, repositories (interfaces), use cases
├── data/         models, datasources, repository impl
└── presentation/ cubits, pages, widgets
```

**Règle de dépendance :** Presentation → Domain ← Data

---

## Prérequis

- **Flutter SDK** ≥ 3.3.4
- **Dart** ≥ 3.3.4
- **API backend** en cours d’exécution ([`education_fr_api`](../education_fr_api))
- Xcode (iOS) / Android Studio (Android) selon la plateforme cible

Vérifier l’installation :

```bash
flutter doctor
```

---

## Démarrage rapide

### 1. Lancer l’API backend

```bash
cd ../education_fr_api
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Documentation : [http://localhost:8000/docs](http://localhost:8000/docs)

### 2. Installer les dépendances

```bash
cd education_fr_app
flutter pub get
```

### 3. Générer le code (routes, freezed, json)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Lancer l’application

```bash
flutter run
```

---

## Configuration API

L’URL de base est définie dans `lib/core/network/api_constants.dart`.

### Override au build (recommandé)

```bash
# Simulateur iOS / Web
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Émulateur Android
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Appareil physique (remplacer par l’IP de votre machine)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

### Endpoints utilisés

| Méthode | Route | Usage |
|---------|-------|-------|
| `POST` | `/auth/register` | Inscription élève |
| `POST` | `/auth/login` | Connexion |
| `GET` | `/auth/me` | Session courante (splash) |
| `GET` | `/progress` | Récupérer la progression |
| `PUT` | `/progress` | Sauvegarder la progression |

> Le JWT est injecté automatiquement via `AuthInterceptor` sur toutes les requêtes authentifiées.

---

## Génération de code

Après toute modification de fichiers annotés (`@freezed`, `@JsonSerializable`, `@RoutePage`) :

```bash
dart run build_runner build --delete-conflicting-outputs
```

Mode watch (développement actif) :

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Régénérer les icônes de l’app

```bash
dart run flutter_launcher_icons
```

Configuration : `flutter_launcher_icons.yaml` → source `assets/icons/app_icon.png`

---

## Structure du projet

```
lib/features/
├── auth/
│   ├── domain/         User, AuthRepository, Login/Register/Logout use cases
│   ├── data/           AuthRemoteDataSource, UserModel, TokenResponseModel
│   └── presentation/   LoginScreen, RegisterScreen, LoginCubit, RegisterCubit
├── progress/
│   ├── domain/         Progress entity, Get/Save/MarkLesson/AddQuiz use cases
│   └── data/           Remote + local datasources, cache fallback
├── theme/              ThemeCubit, persistance light/dark/system
├── splash/             SplashCubit (auth check + délai animation)
├── onboarding/         OnboardingScreen (stories), WelcomeScreen
├── main/               MainScreen (AutoTabsScaffold + bottom nav)
├── home/               HomeScreen (dashboard élève)
├── leaderboard/        LeaderboardScreen (placeholder)
└── profile/            ProfileScreen (thème, logout)
```

---

## Navigation & écrans

### Flux utilisateur

```
Splash
  ├── Session valide ──────────────────────► Main (tabs)
  └── Non connecté
        ├── Onboarding non vu ──► Onboarding (3 stories) ──► Welcome
        └── Onboarding vu ──────► Welcome
                                      ├── Register ──► Main
                                      └── Login ─────► Main

Main (Bottom Nav)
  ├── Accueil      /home
  ├── Classement   /leaderboard
  └── Profil       /profile
```

### Routes AutoRoute

| Route | Écran |
|-------|-------|
| `/` (initial) | `SplashScreen` |
| `/onboarding` | `OnboardingScreen` |
| `/welcome` | `WelcomeScreen` |
| `/login` | `LoginScreen` |
| `/register` | `RegisterScreen` |
| `/main` | `MainScreen` (tabs) |
| `/main/home` | `HomeScreen` |
| `/main/leaderboard` | `LeaderboardScreen` |
| `/main/profile` | `ProfileScreen` |

---

## Intégration backend

### Inscription

Champs envoyés à `POST /auth/register` :

| Champ | Exemple |
|-------|---------|
| `email` | `eleve@example.com` |
| `password` | min. 6 caractères |
| `firstName` | `Achref` |
| `lastName` | `Chaabani` |
| `level` | `2e année primaire` |

**Niveaux disponibles :**

- 1ère année primaire
- 2e année primaire
- 3e année primaire
- 4e année primaire
- 5e année primaire
- 6e année primaire

### Catégories affichées (accueil)

Alignées avec le backend / admin :

| Leçons | Quiz |
|--------|------|
| Grammaire, Conjugaison, Orthographe, Vocabulaire, Lecture, Dictée | Grammaire, Conjugaison, Orthographe, Vocabulaire |

### Progression

- **Remote-first** : lecture/écriture via `/progress`
- **Fallback cache** : `SharedPreferences` si le réseau est indisponible
- Use cases : `GetProgress`, `SaveProgress`, `MarkLessonCompleted`, `AddQuizScore`

### Gestion des erreurs

```dart
Either<Failure, T>
  ├── Left(ServerFailure | NetworkFailure | AuthFailure | CacheFailure…)
  └── Right(success)
```

Les intercepteurs Dio mappent les codes HTTP vers des `Failure` typées.

---

## Thème & assets

### Thème

- Palettes **light** et **dark** (`AppColors`, `AppTextStyles`)
- Bascule depuis Welcome ou Profil
- Modes : `ThemeMode.light` | `ThemeMode.dark` | `ThemeMode.system`

### Assets

```
assets/
├── icons/
│   ├── app_icon.png          # Icône launcher
│   └── icon_screens.png      # Badge écrans
└── images/
    ├── welcome_hero_light.svg / welcome_hero_dark.svg
    ├── welcome_hero_light_alt.svg / welcome_hero_dark_alt.svg
    └── find_friends_light.svg / find_friends_dark.svg
```

---

## Build & déploiement

### Analyse statique

```bash
flutter analyze
```

### Tests

```bash
flutter test
```

### Android (APK debug)

```bash
flutter build apk --debug
```

### Android (release)

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.votre-domaine.com
```

### iOS

```bash
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.votre-domaine.com
```

---

## Dépannage

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| Chargement infini après register/login | Erreur de parsing JSON (`access_token` vs `accessToken`) | Vérifier que `TokenResponseModel` utilise `FieldRename.snake` |
| `Connection refused` | Mauvaise URL API | Utiliser `--dart-define=API_BASE_URL=...` adapté à la plateforme |
| Android emulator + `localhost` | `localhost` = l’émulateur lui-même | Utiliser `http://10.0.2.2:8000` |
| Appareil physique + `localhost` | `localhost` = le téléphone | Utiliser l’IP LAN de votre PC (ex. `192.168.x.x:8000`) |
| Routes introuvables | Code généré manquant | `dart run build_runner build --delete-conflicting-outputs` |
| Onboarding ne s’affiche plus | Déjà vu (`has_seen_onboarding`) | Supprimer les données app ou réinitialiser `SharedPreferences` |
| Hot reload ne met pas à jour les routes | Changement de `@RoutePage` | Hot **Restart** (`R`) ou relancer `flutter run` |

---

## Projets liés

| Projet | Rôle |
|--------|------|
| [`education_fr_api`](../education_fr_api) | Backend FastAPI (auth, progress, contenu) |
| [`education_fr_admin`](../education_fr_admin) | Panel d’administration Angular |

---

## Licence

Projet privé — usage interne DELFy / Education FR.
