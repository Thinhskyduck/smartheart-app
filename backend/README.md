# Pentapulse Backend

This is the Node.js backend for the Pentapulse Pharmacy App. It uses Express, MongoDB (Mongoose), and JWT for authentication.

## Setup

1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Start the server:
    ```bash
    npm start
    # or for development with auto-reload:
    npx nodemon server.js
    ```

## Environment Variables

The `.env` file is pre-configured with the MongoDB URI provided.
`PORT=5000`

## API Endpoints

### Authentication
-   `POST /api/auth/register`: Register a new user.
    -   Body: `{ "fullName": "Name", "phoneNumber": "1234567890", "password": "password", "role": "patient" }`
-   `POST /api/auth/login`: Login.
    -   Body: `{ "phoneNumber": "1234567890", "password": "password" }`
-   `GET /api/auth/me`: Get current user info. (Requires Token)

### User
-   `PUT /api/user/profile`: Update profile.
-   `POST /api/user/link-guardian`: Link a guardian.
    -   Body: `{ "guardianCode": "123456" }`

### Health Metrics
-   `POST /api/health`: Add a metric.
    -   Body: `{ "type": "bp", "value": "120/80", "unit": "mmHg" }`
-   `GET /api/health`: Get all metrics history.
-   `GET /api/health/latest`: Get latest metrics for dashboard.

### Medications
-   `GET /api/medications`: Get all medications.
-   `POST /api/medications`: Add medication.
    -   Body: `{ "name": "Panadol", "dosage": "500mg", "time": "08:00", "quantity": 10, "session": "morning" }`
-   `PUT /api/medications/:id`: Update medication (e.g., mark as taken).
-   `DELETE /api/medications/:id`: Delete medication.

## Connecting Flutter App

To connect your Flutter app to this backend:
1.  Find your computer's IP address (e.g., `192.168.1.x`).
2.  Update your Flutter API service to point to `http://<YOUR_IP>:5000/api`.
3.  Use `http` package in Flutter to make requests.
