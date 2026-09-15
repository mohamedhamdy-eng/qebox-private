# qebox_private

## Q Bot AI setup

Q Bot works with local support answers when no AI key is configured. For Gemini
development testing, create an API key in Google AI Studio and run:

```powershell
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

Do not commit the key. `--dart-define` is suitable for local testing, but a
production app must call Gemini through a secured backend so the key cannot be
extracted from the application package.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
