# GrindTime-Preview
**Preview of GrindTime**, a productivity focused social app build with SwiftUI.
This repo showcases the timer engine and photo capture workflow used in the full GrindTime app. In this README I will also describe what GrindTime is in more detail and provide screen shots of the current working version of the app.

LINK TO WEBSITE NOW LIVE AT: https://www.grindtime.app

---

## Overview 🌎
GrindTime is an iOS mobile app designed to track studying to make it feel more interactive, competitive and rewarding. 
Users log focused work sessions using a guided photo flow (workspace + selfie), tracking consistency through visual analytics and share progress with friends with an instagram style feed.

The full version of GrindTime includes a profile page, session history, heatmaps, social features, and a competitive leaderboard.
This preview includes only the UI and interaction logic for the timer and camera flow.
All other functionality, backend logic, session storage and proprietary features remain private.

---

## Core Features 💪
This section describes the full GrindTime app.

**⭐️ Productivity Timer**
* High precision session timing
* Start/Pause/Stop/Restart flow
* Smooth live updates using CACurrentMediaTime()
* Automatic session logging once both start/end photos are captured

**⭐️ Guided Photo Capture**
* Workspace + Selfie capture (start and end)
* Automatic camera switching (front and back)
* Clean, Snapchat style full screen capture UI
* Debounced image handling, downscaling, and memory safe processing
* When capturing images, user can select between different camera settings such as ultra wide (x0.5), normal (x1.0), or zoomed in (x2.0) depending on phone capabilities.

**⭐️ Personal Profile Page**
* When creating an account, user sets name, username and password
* On profile page, user can update, username, profile picture and bio
* User profiles includes total monthly gring time
* Activity heatmap calander to visualize study/grind consistency
* Full instagram style session gallery
* Tap to view posts (workspace + selfie, swipe through start/end)

**⭐️ Feed & Social**
* Follow friends to see their posts on your feed
* Scrollable feed of friends study/work sessions
* Like and comment interactions (future feature)

**⭐️ Leaderboard (premium + future feature)**
* Compare monthly grind times with friends
* Long term streaks and consistency metrics
* First place on leaderboard awards

**⭐️ Backend & Sync (Private)**
* The full app uses a secure back end for:
  * User authentication
  * Session Storage
  * Image uploads
  * Social graph
  * Feed + leaderboard generation
  *(All backend code is private and not included in this preview repository)*

**⭐️ Privacy and Security**
* Minimal data collection
* Strong user controlled permissions
* All sync done over secure channels

---

## Tech Stack 📱
These describe the actual full app, not just the preview.

**iOS App**
* SwiftUI - main UI framework
* AVFoundation - custom camera system (Workspace and selfie image capture)
* Core Data - local storage + caching
* Swift Concurrency - async capture and image processing
* PhotosUI & UIKit Interop - image rendering, compression, and downscaling

**Backend (full app, private)**
* Supabase
  * Postgres database
  * Row-level security (RLS)
  * Auth (email/passwork + OAuth)
  * Storage for user images
  * Edge functions for session processing

**Architecture**
* MVVM + service based modular structure
* Fully offline capable timer
* Automatic background safe session tracking
---

## Screenshots & Design 📸

To see screenshots and learn more, visit my website at: https://www.grindtime.app

---

## License 🔐

Copyright © 2025 Vlad Petrariu. All rights reserved.

This repository is provided for preview and educational purposes only.
No part of this project, including code, designs, or assets may be copied,
modified, distributed, or used for commercial purposes without explicit
written permission from the author.

---

## Author
**Vlad Petrariu**
- [LinkedIn] www.linkedin.com/in/vladpetrariu777 
- [GitHub] https://github.com/VladPetrariu
