# GrindTime

**A productivity-focused social iOS app for tracking study and work sessions.**

![Platform](https://img.shields.io/badge/platform-iOS%2018.2+-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![Status](https://img.shields.io/badge/status-TestFlight%20Beta-green)

---

## Overview

GrindTime is a native iOS app that turns focused work into a social experience. Users start a high-precision timer, capture workspace and selfie photos at the start and end of each session, and share their progress with friends through an Instagram-style feed. The app tracks consistency through heatmaps and leaderboards, making productivity visible and competitive.

Built entirely in SwiftUI with 48 Swift source files across 6 organized modules. Backend powered by Supabase (Postgres, Auth, Storage, RLS).

---

## Key Features

- **Session Timer** — Centisecond-precision stopwatch with start/pause/stop/restart flow and persistence across app kills
- **Guided Photo Capture** — Workspace + selfie photos at session start and end, with multi-lens camera selection and full-screen Snapchat-style UI
- **Social Feed** — Follow friends and browse their sessions in a scrollable, paginated feed
- **Profile** — Editable username, bio, and profile picture with monthly grind time totals
- **Activity Heatmap** — Per-day duration aggregation with dynamic opacity gradients to visualize consistency
- **Leaderboard** — Compare monthly grind times with friends (premium, in development)
- **Session Gallery** — Tap any session to swipe through start/end workspace and selfie photos

---

## Architecture & Technical Highlights

### Overall Architecture
MVVM + Repository + Service layer pattern. The codebase is organized into 6 modules: **Core**, **Features**, **Models**, **Repositories**, **Services**, and **Config**. All async work uses Swift's structured concurrency (`async/await`, `TaskGroup`), with `@MainActor` isolation for UI-bound state.

### Timer Engine
Accumulation-based timing using `CACurrentMediaTime()` for centisecond precision. A pause/resume state machine tracks elapsed intervals, and the accumulated duration persists to `UserDefaults` so sessions survive app kills and backgrounding.

### Camera System
Custom AVFoundation camera with multi-lens selection — ultra-wide (0.5x), wide (1.0x), and telephoto (2.0x) — using FOV-based detection to distinguish optical from digital zoom. Front-camera captures use a screen flash simulation for low-light selfies. The preview shows a mirrored image (natural for selfies) while the captured output is saved unmirrored.

### Session Sync Pipeline
After a session ends, images upload in parallel via `TaskGroup` (up to 4 concurrent uploads). Sync uses timestamp-based incremental filtering to avoid re-uploading, with duplicate prevention through remote ID checks. Uploaded images use signed URL caching to minimize redundant storage requests.

### Image Processing
JPEG compression at 50% quality with 900px max-dimension downscaling to keep uploads small. Capture callbacks are debounced with a 250ms guard to prevent duplicate frames.

### Feed
Queries use PostgREST OR-filter disjunctions across the user's social graph, joining profile data in a single request. Pagination is offset/limit-based, rendered in a `LazyVStack` for smooth scrolling.

### Heatmap
Per-day session duration aggregation rendered as a calendar grid with dynamic opacity gradients proportional to daily grind time.

### Authentication
Supabase Auth with PKCE flow. Supports username-to-email fallback login (users can sign in with either). Debounced dual availability checks validate both email and username uniqueness during signup. Incomplete signups are gated behind a profile completion screen.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **UI** | SwiftUI, PhotosUI, UIKit interop |
| **Camera** | AVFoundation (multi-lens, front/back, flash simulation) |
| **Concurrency** | Swift structured concurrency (`async/await`, `TaskGroup`) |
| **Local Storage** | Core Data, UserDefaults |
| **Backend** | Supabase v2.31.2 (Postgres, Auth, Storage, Edge Functions) |
| **Security** | Row-level security (RLS), PKCE auth flow, minimal data collection |
| **Min Deployment** | iOS 18.2 |

---

## Preview Code

This public repository contains the **timer engine** and **photo capture workflow** — the two most technically interesting subsystems in GrindTime. All other functionality (backend integration, social features, session storage, feed, leaderboard) remains in the private repository.

---

## Screenshots & Website

Visit **[grindtime.app](https://www.grindtime.app)** for screenshots, feature details, and TestFlight access.

---

## License

Copyright 2025 Vlad Petrariu. All rights reserved.

This repository is provided for preview and portfolio purposes only. No part of this project may be copied, modified, distributed, or used for commercial purposes without explicit written permission from the author.

---

## Author

**Vlad Petrariu**
- [LinkedIn](https://www.linkedin.com/in/vladpetrariu777)
- [GitHub](https://github.com/VladPetrariu)
