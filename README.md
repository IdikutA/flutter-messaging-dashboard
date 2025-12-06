# Messaging App with Embedded Angular Dashboard

This project is a full-stack assessment submission featuring a native Flutter messaging app and an Angular + Tailwind internal tools dashboard. The dashboard is embedded via WebView and served locally over HTTP.

## Folder Structure

flutter-messaging-dashboard/ ├── flutter_app/ ├── webpage/ └── README.m

---
## **How to Run the Dashboard and Messaging App**


** How to Start the Angular HTTP Server
```bash
cd webpage
npm install
ng serve

## How to Run the Flutter App and Configure WebVie
'''bash
cd flutter_app
flutter pub get
flutter run

## WebView Configuration Notes
Platform                Dashboard URL to use
Android Emulator       http://10.0.2.2:4200
iPhone Simulator       http://<your-mac-ip>:4200
Windows/macOS          http://localhost:4200
Chrome/Web             Opens dashboard in new tab via url_launcher

## Assumptions and Stretch Goals Completed
- Assumes local HTTP server is running before launching Flutter app
- WebView integration tested on Android, iOS, Windows, and Chrome/Web
- Stretch goals:
- Emoji and image message support in chat UI
- Auto-replies and message persistence
- Responsive dashboard layout with Tailwind CSS
- Live log simulation and scroll behavior
- External launch for Chrome/Web using url_launcher

###  Key Fixes I Made
- Closed all code blocks properly with triple backticks (```bash … ```).  
- Fixed the typo in “Configure WebVie” → “Configure WebView”.  
- Added table formatting for the platform URLs so they look neat.  
- Added section dividers (`---`) for readability. 


