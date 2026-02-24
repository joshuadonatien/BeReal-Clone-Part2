# BeReal Clone – Part 2

A UIKit iOS app that replicates core BeReal functionality, built with Parse (Back4App) as the backend.

## Features

### Required
- **Camera support** — Tap the camera icon to choose between taking a live photo or selecting from your photo library
- **24-hour blur gate** — Other users' posts are hidden (blurred) until you upload your own photo for the day
- **Comments** — Each post has a comment section showing the commenter's username and comment text
- **Time & location on posts** — Every post displays a relative timestamp (e.g. "2h ago") and GPS coordinates when location is enabled

### Stretch
- **Daily push notification** — App schedules a daily reminder to post; notification is cancelled on logout

## Demo

<!-- Replace the line below with your actual GIF after recording it -->
![App Demo](demo.gif)

## Setup

1. Clone the repo
2. Run `pod install`
3. Open `BeReal-Clone.xcworkspace`
4. Build & run on a device or simulator (iOS 16+)

## Tech Stack

- UIKit (programmatic + storyboard)
- Parse SDK / Back4App
- CocoaPods
- UserNotifications framework
- CoreLocation
