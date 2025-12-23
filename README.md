# PentaPulse – Chronic Heart Failure Monitoring Application

PentaPulse is a healthcare application prototype designed to support chronic heart failure monitoring using smartwatch data collected via Google Health Connect.
The system processes health indicators through a Node.js backend and integrates an AI model to classify patient conditions into stable, warning, and critical levels.

The application provides core features such as medication reminders, role-based access for patients and doctors, health data visualization, and AI-assisted prescription scanning.
All main functionalities are fully implemented, and the backend API is deployed on Render, allowing the app to run directly without local backend setup.

This project serves as a technically complete healthcare application prototype and a foundation for future clinical validation and real-world deployment.

## Repository layout

- Flutter app: [lib](lib/)
- Node.js API: [backend](backend/)
- Web deployment config: [netlify.toml](netlify.toml), [netlify_build.sh](netlify_build.sh)
- Flutter dependencies/config: [pubspec.yaml](pubspec.yaml)

## Features (high level)

- Authentication and role-based routing (patient/doctor/guardian)
- Health metrics logging + history and dashboard visualization
- Medication scheduling, reminders, and local notifications
- Prescription image scanning endpoint (Gemini) to extract structured medication instructions (backend)


## Tech stack

**Frontend**

- Flutter (Dart)
- Local notifications: `flutter_local_notifications`
- Charts: `fl_chart`
- Device/permission utilities: `permission_handler`, `shared_preferences`

**Backend**

- Node.js + Express
- MongoDB via Mongoose
- JWT auth
- Email/OTP via Brevo API (Axios)
- Gemini integration via `@google/generative-ai`

## Prerequisites

- Flutter SDK installed and available on PATH
- Node.js 18+ recommended (for the backend)
- MongoDB connection string (Atlas or local)

## Quick start (Flutter app)

From the repository root:

1. Install Flutter dependencies:
	- `flutter pub get`
2. Run the app:
	- `flutter run`

### API base URL configuration

The app’s API endpoints are configured in [lib/services/api_config.dart](lib/services/api_config.dart).

- Default production base URL:
  - `https://pentapulse-app.onrender.com`
- For local testing, set `BASE_URL` to your local server (examples are already documented in the file):
  - Android Emulator: `http://10.0.2.2:5000`
  - Physical device: `http://<YOUR_COMPUTER_IP>:5000`
  - iOS Simulator: `http://localhost:5000`

Tip (Android physical device): if you run the backend on your PC and the phone is on the same network, use your PC’s LAN IP.

## Quick start (Backend API)

From the repository root:

1. Go to the backend folder:
	- `cd backend`
2. Install dependencies:
	- `npm install`
3. Create a `.env` file in [backend](backend/) with required variables (example below).
4. Run the server:
	- `npm run dev` (recommended for development)
	- `npm start` (production-like)

The API listens on `PORT` (defaults to `5000`) and exposes routes under `/api` (see [backend/server.js](backend/server.js)).

### Backend environment variables

The backend reads these variables via `process.env`:

- `MONGO_URI` (required): MongoDB connection string
- `JWT_SECRET` (required): secret used to sign/verify JWT tokens
- `PORT` (optional): API port (default: 5000)

Optional (feature-specific):

- `GEMINI_API_KEY`: enables the prescription scan endpoint
- `EMAIL_USER`: verified sender email for Brevo
- `EMAIL_PASS`: Brevo API key

Example `.env`:

```bash
PORT=5000
MONGO_URI=mongodb+srv://<user>:<pass>@<cluster>/<db>?retryWrites=true&w=majority
JWT_SECRET=change_me

# Optional features
GEMINI_API_KEY=change_me
EMAIL_USER=you@yourdomain.com
EMAIL_PASS=change_me
```

## Deployment notes

- **Web (Netlify):** [netlify.toml](netlify.toml) runs [netlify_build.sh](netlify_build.sh) and publishes `build/web`.
- **API hosting:** the Flutter app currently points to an onrender.com base URL in [lib/services/api_config.dart](lib/services/api_config.dart).

## Common troubleshooting

- **App can’t reach API on a physical phone:** ensure your phone and PC are on the same network and `BASE_URL` uses your PC’s LAN IP (not `localhost`).
- **Android emulator networking:** use `10.0.2.2` to reach the host machine.
- **401 / auth failures:** confirm `JWT_SECRET` is set and consistent between restarts; confirm requests send `x-auth-token` header (backend auth middleware).
- **Prescription scan fails:** ensure `GEMINI_API_KEY` is set and the backend can access the internet.

## Scripts

**Flutter**

- `flutter pub get`
- `flutter run`
- `flutter test`
- `flutter build web`

**Backend**

- `npm run dev`
- `npm start`

## Usage & Disclaimer

This project is a technical prototype developed for academic and demonstration purposes.  
It is not intended for clinical diagnosis or medical treatment.
