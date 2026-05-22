# AquaForge AI Deployment & Architecture Guide

## System Overview
AquaForge AI is a distributed, full-stack application spanning:
1. **Mobile Application**: Flutter (iOS/Android)
2. **Web Dashboard**: Next.js (Web/Enterprise)
3. **Backend Services**: Firebase Cloud Functions + Firestore
4. **IoT Edge**: Python/C++ MQTT telemetry
5. **Smart Contracts**: Solidity on EVM-compatible chain

## 1. Firebase Backend Deployment
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init` in `/backend`
4. Deploy Functions & Security Rules:
   ```bash
   cd backend/functions
   npm install
   firebase deploy --only functions,firestore
   ```

## 2. Flutter Mobile App Deployment
1. Ensure Flutter 3.29+ is installed.
2. Run `flutter doctor` to verify environment.
3. Fetch dependencies: `flutter pub get`
4. Build for iOS (requires Xcode):
   ```bash
   flutter build ipa --release
   ```
5. Build for Android:
   ```bash
   flutter build appbundle --release
   ```

## 3. Next.js Web Dashboard Deployment
1. Vercel is recommended for Next.js edge deployments.
2. Link the repository to Vercel or run locally:
   ```bash
   cd web
   npm run build
   npm start
   ```

## 4. Smart Contract Deployment
1. Use Hardhat or Truffle to compile `smart_contracts/AquaWarranty.sol`.
2. Deploy to a low-fee chain (e.g., Polygon) to minimize transaction costs for immutable warranties.
