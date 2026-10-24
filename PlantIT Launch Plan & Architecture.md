# PlantIT Launch Plan & Technical Architecture

## A Bootstrapped Mobile-First Platform for Urban Farming

---

## Executive Summary

**Your Setup:**

- Solo/small team development
- Flutter (iOS + Android from one codebase)
- Bootstrap budget (free/open-source tools)
- Kerala/South India focus, expanding later
- Balcony/terrace gardens, then small backyards
- Quality over speed—realistic timeline

**Recommended Tech Stack:**

- **Frontend:** Flutter + Dart
- **Backend:** Firebase (Firestore + Cloud Functions)
  - *Why:* Best solo developer experience, free tier covers MVP, scales easily
- **AI/ML:** Hybrid approach
  - Google Cloud Vision API (for space analysis)
  - TensorFlow Lite (local crop recommendation model)
  - Open agricultural databases (crop metadata)
- **Weather/Pest Data:** Open APIs (OpenWeatherMap, Agro APIs)
- **DevOps:** GitHub + GitHub Actions for CI/CD

---

## Phase 1: MVP Launch (Months 1–3)

### "AI Farm Planning + Gamification Core"

**Goal:** Users can upload a space photo → get AI crop suggestions → start tracking a farm with points/badges.

### 1.1 AI Farm Planning Engine

#### What It Does

1. User uploads photo of balcony/terrace
2. AI analyzes: light conditions, dimensions, existing plants
3. Returns: crop recommendations + layout suggestions + shopping list

#### Implementation (Solo-Friendly)

**Space Analysis:**

- **Google Cloud Vision API** (free tier: 1,000 requests/month)
  - Detects light, shadows, space dimensions from image
  - Identifies existing plants
  - Returns structured data (brightness, area, obstacles)

**Crop Recommendation Engine:**

- **Data Source:** Build a local SQLite database of Kerala crops
  - Crop name, water needs, light requirements, growth time, season
  - Source: ICAR (Indian Council of Agricultural Research) data, public agriculture databases
  - Start with 20–30 high-success urban crops (tomato, mint, basil, spinach, coriander, beans, etc.)
- **Logic:** Simple scoring algorithm (no heavy ML needed initially)

  ```
  Compatibility Score = 
    (Light Match × 0.4) + 
    (Season Match × 0.3) + 
    (Space Available × 0.2) + 
    (Beginner-Friendly × 0.1)
  ```
  - Can be built in Cloud Functions (Node.js)
  - Returns top 5 crop suggestions with reasoning

**Layout Suggestions:**

- Simple grid-based layout planner
- Calculates spacing, companion planting (e.g., basil + tomato = good)
- Generates shopping list with local nursery recommendations

#### Tech Setup

```
Frontend (Flutter):
  - Image picker + upload widget
  - Space dimensions input (optional manual entry)
  - Display crop cards with match scores

Backend (Firebase):
  - Cloud Function: analyzeSpace()
    ├── Calls Google Vision API
    ├── Queries crop compatibility DB
    └── Returns top 5 crops + layout
  
  - Firestore: crops collection
    └── {cropId, name, water, light, season, difficulty, ...}
```

#### Cost: \~$0 (within free tiers)

---

### 1.2 Gamification System

#### What It Does

- Users earn points for actions: planting, watering, harvesting
- Badges for milestones (first harvest, streak of 7 days, etc.)
- Leaderboard (optional for MVP—add later)
- Streak counter (consecutive days of care)

#### Implementation

**Data Model (Firestore):**

```
users/{userId}
  ├── profile
  │   ├── username, avatar, total_points
  │   └── joined_date
  └── stats
      ├── current_streak, best_streak
      ├── plants_grown, harvests_count
      └── badges_earned [array]

farms/{farmId}
  ├── userId, name, created_at
  ├── crops [array of {cropId, planted_date, stage}]
  └── actions [array of activity logs]
```

**Point System:**

- Plant a crop: 10 points
- Log watering: 2 points
- Harvest: 50 points
- 7-day streak: 25 bonus points
- First harvest badge: 100 points

**Simple UI:**

- Home dashboard: profile card (points, streak, badges)
- Action buttons: "I watered today" → +2 points, streak++
- Badge showcase gallery

#### Cost: \~$0 (Firestore free tier)

---

### 1.3 Basic User Onboarding & Auth

**Firebase Authentication:**

- Email/password sign-up (free tier covers MVP)
- Optional: Google Sign-In

**Onboarding Flow:**

1. Sign up → name + profile pic
2. "What's your growing space?" → photo upload
3. AI suggests crops → user selects 2–3
4. "Let's start!" → enter farm name
5. Home dashboard loads

---

### 1.4 Phase 1 Deliverables

- [ ] Flutter app skeleton (auth, navigation, state management)
- [ ] Space analysis feature (Vision API integration)
- [ ] Crop database (30 crops with metadata)
- [ ] Gamification dashboard (points, badges, streak)
- [ ] Cloud Functions for farm planning logic
- [ ] Firestore schema + security rules
- [ ] Beta testing with 10–20 users

**Timeline:** 3 months (solo dev, \~40 hrs/week) **Launch:** Beta release on Android first (faster iteration), iOS after

---

## Phase 2: Growth Features (Months 4–6)

### "Care Guidance + Weather/Pest Alerts"

Once MVP is live and gathering user feedback, add:

### 2.1 Smart Care Guidance

**What It Does:**

- Personalized daily/weekly care instructions
- "Your tomato needs water today" (based on weather, soil moisture estimate)
- Step-by-step rescue guides if crop is failing

**Implementation:**

- Simple rule engine in Cloud Functions
- Input: crop type, weather, days since watering
- Output: actionable care tasks
- Optional: integrate soil moisture sensor APIs later

### 2.2 Weather & Pest Alerts

**Weather Integration:**

- OpenWeatherMap API (free tier)
- Hyperlocal alerts: "Heavy rain expected—cover seedlings"
- Pest season alerts tied to Kerala agricultural calendar

**Pest Database:**

- Build local pest database (common Kerala pests)
- Image recognition (optional): user uploads leaf photo → pest ID + treatment

**Cost:** \~$0–$20/month (OpenWeatherMap free tier covers MVP)

### 2.3 Community Features (Optional)

- Seed/sapling exchange board (nurseries + local gardeners)
- Success stories (users share photos, tips)
- Beginner Q&A forum

---

## Phase 3: Scale & Monetization (Months 7+)

- Expand to other regions (all India, then global)
- Premium features: advanced pest ID, compost tracking, crop analytics
- Partnerships with local nurseries (commission-based referrals)
- Corporate CSR programs (office gardening competitions)

---

## Recommended Tech Stack Details

### Backend: Firebase vs. Node.js + PostgreSQL

| Aspect | Firebase | Node.js + PostgreSQL |
| --- | --- | --- |
| Setup time | 1 day | 1–2 weeks |
| Cost (MVP) | Free tier | \~$5–$10/month |
| Scaling | Auto (serverless) | Manual DevOps |
| Offline support | Good | Requires extra setup |
| Solo dev experience | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**Recommendation:** **Firebase for MVP.** It's the fastest path to launch solo. Migrate to Node.js later if you need custom backend logic or want cost control at scale.

---

### Flutter Best Practices for This Project

**State Management:** Provider or Riverpod (lighter than BLoC for solo dev)

**Key Packages:**

```yaml
dependencies:
  firebase_core: latest
  cloud_firestore: latest
  firebase_auth: latest
  firebase_storage: latest
  image_picker: latest
  google_mlkit_image_labeling: latest  # for on-device crop detection
  http: latest  # for API calls
  cached_network_image: latest
  intl: latest  # for localization (Malayalam + English)
```

**Folder Structure:**

```
lib/
  ├── screens/
  │   ├── auth/ (sign up, login)
  │   ├── onboarding/ (space photo, crop selection)
  │   ├── home/ (dashboard, points, badges)
  │   ├── farm/ (crop details, care instructions)
  │   └── settings/
  ├── services/
  │   ├── firebase_service.dart
  │   ├── api_service.dart (Vision API, Weather API)
  │   └── gamification_service.dart
  ├── models/ (User, Farm, Crop, Action, Badge)
  ├── widgets/ (reusable components)
  └── utils/ (helpers, constants)
```

---

## Development Roadmap

### Month 1: Foundation

- [ ] Flutter project setup + Firebase
- [ ] Auth (email/password + Google Sign-In)
- [ ] Basic navigation & UI scaffolding
- [ ] Firestore schema design

### Month 2: AI Planning Engine

- [ ] Space analysis (Vision API integration)
- [ ] Crop database (build + seed Firestore)
- [ ] Recommendation algorithm
- [ ] Layout planner UI

### Month 3: Gamification & Polish

- [ ] Points & badges system
- [ ] Streak counter
- [ ] Dashboard UI
- [ ] User testing (10–20 beta users)
- [ ] Bug fixes & performance optimization
- [ ] Play Store submission (beta/internal testing)

### Months 4–6: Growth Phase

- [ ] Weather integration
- [ ] Pest alerts + database
- [ ] Care guidance system
- [ ] Community features (seed exchange board)

---

## Free Tools & Resources

| Tool | Purpose | Cost |
| --- | --- | --- |
| Firebase | Backend + database | Free tier (good for MVP) |
| Flutter | Mobile framework | Free |
| GitHub | Version control + CI/CD | Free for public repos |
| Google Cloud Vision | Image analysis | Free tier (1k/month) |
| OpenWeatherMap | Weather data | Free tier |
| ICAR Data | Crop info | Free (public data) |
| Figma | UI/UX design | Free tier |
| Android Studio | IDE | Free |
| Postman | API testing | Free |

---

## Deployment Strategy

### Android (Faster MVP Launch)

1. Build APK locally
2. Internal testing on devices
3. Closed beta via Google Play Console (internal + 20 testers)
4. Iterate based on feedback (2–3 weeks)
5. Public release to Play Store

### iOS (2–4 Weeks Later)

- Build IPA
- TestFlight beta testing
- App Store submission (requires $99/year developer account)

---

## Success Metrics (First 3 Months)

- **Adoption:** 100+ downloads
- **Engagement:** 40%+ weekly active users
- **Crop Success Rate:** 70%+ users report successful first harvest
- **Retention:** 30%+ 30-day retention (typical for utility apps)
- **Gamification:** 60%+ of users earning at least one badge

---

## Challenges & Mitigation

| Challenge | Mitigation |
| --- | --- |
| AI accuracy (crop suggestions) | Start simple (rule-based), gather user feedback, improve algorithm iteratively |
| Weather/pest data for Kerala | Use OpenWeatherMap + build local pest database with agronomists/farming forums |
| Offline support | Cache crop data locally, sync when online (Firebase supports this) |
| Indian payment systems (future) | Razorpay or PhonePe integration (later phase) |
| Malayalam localization | Use `intl` package, hire translator for \~50 key phrases (low cost) |

---

## Next Steps

1. **Week 1:** Set up Flutter + Firebase project, design Firestore schema
2. **Week 2:** Build auth flow + basic UI
3. **Week 3:** Integrate Google Vision API, build crop database
4. **Week 4:** Implement recommendation algorithm
5. **Ongoing:** User feedback loop, iterate UI/UX

---

## Resources for You

### Learning

- [Flutter Official Docs](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Google Cloud Vision API](https://cloud.google.com/vision)
- [Indian Agricultural Data](https://www.icar.org.in/)

### Kerala-Specific

- ICAR-CTCRI (Cassava and Tapioca research)
- Kerala Agricultural University (KAU) publications
- Local farming communities on WhatsApp/Facebook groups

### Design Inspiration

- Strava (gamification + streaks)
- PlantSnap (image recognition)
- Soil app (simple, focused farming UX)

---

**Ready to build? Start with Firebase + Flutter auth in Week 1. You've got this.** 🌱