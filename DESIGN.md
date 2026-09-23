# PlantIT — Architecture & Design (Phase B)

> Companion to `PLAN.md`. Decisions marked **[D]** were made by me per the working agreement (most-common/lowest-risk option) — flag any you want changed.

---

## 1. High-level architecture

```
┌─────────────────────────────┐        ┌──────────────────────────────┐
│  Flutter App (Android)      │        │  Node.js REST API "plantit-api" │
│  ─ Firebase Auth            │◄──────►│  Express, stateless           │
│  ─ Firestore (user data)    │  HTTPS │  ─ /api/plan   (Planner)      │
│  ─ Storage (photos)         │        │  ─ /api/alerts (Weather+Pest) │
│  ─ TFLite (leaf disease,    │        │  ─ /api/rescue-steps (Rescue) │
│    on-device inference)     │        │  ─ /api/peer-alerts (Peers)   │
│                             │        │  ─ /api/crops, /api/diseases  │
└──────────────┬──────────────┘        └───────┬──────────────┬───────┘
               │                               │              │
        ┌──────▼──────┐                 ┌──────▼─────┐  ┌─────▼──────────┐
        │  Firebase   │                 │ Open-Meteo │  │ Crop & Disease │
        │ Auth/Fire-  │                 │ (free, no  │  │ Knowledge Base │
        │ store/Store │                 │  API key)  │  │ (JSON in repo) │
        └─────────────┘                 └────────────┘  └────────────────┘
```

**[D1] Backend = standalone Express API on Render free tier**, not Cloud Functions.
Why: Functions deployment requires Firebase **Blaze (paid)** plan; your feasibility study promises free tiers. Logic is written as plain Node modules, so migrating to Cloud Functions later is trivial. Flutter talks to Firestore directly (free SDK) and to the API over HTTPS.

**[D2] Weather source = Open-Meteo** (`open-meteo.com`). Free, no API key, hourly + 7-day forecast, worldwide — perfect for hyperlocal Kozhikode coords.

**[D3] Crop recommendation (MVP) = explainable rule/ranking engine over a curated knowledge base**, not a trained ML model.
Why: matches the abstract's promise ("explains the reasoning"), deterministic and demo-safe, zero training data needed. **[D4]** Post-MVP upgrade path: Google **Gemini Vision free tier** to analyze the uploaded space photo (light/space estimate) and feed the same engine.

**[D5] Disease detection = on-device TFLite** (MobileNetV2 transfer learning on **PlantVillage**, ~38 classes), as your requirements doc specifies. Backend supplies the *recovery guidance* (pedagogy lives in the KB). Optional later: same model converted to TF.js served at `/api/diagnose` for web demos.

**[D6] Alerts are computed on-demand** (app open / pull-to-refresh) and cached in Firestore — no cron jobs needed on free tiers. Scheduled push notifications = post-MVP.

**[D7] Peer pest communication = server-mediated community loop** (Firestore + REST), not raw device-to-device. A published pest report is **area-matched** (default radius **5 km**, same crop) into other users' alert feeds; every report carries a reply **thread** for neighbour-to-neighbour tips. Offline Bluetooth-mesh P2P = future work (good review slide).
**[D8] Location privacy:** reports store coordinates **rounded to 2 decimals (~1.1 km)** + an optional user-typed area name ("Near KMCT campus"); exact home locations are never stored or shown.
**[D9] Rescue → community integration:** after every rescue diagnosis the app prompts **"Warn neighbours?"** — one tap publishes a pre-filled report (crop, pest/disease, photo, area). Turns personal crop failure into community learning, matching the project's pedagogy theme.

## 2. Repository layout (monorepo `plantit/`)

```
plantit/
├── app/                  # Flutter client (M4)
│   └── lib/
│       ├── main.dart, firebase_options.dart
│       ├── screens/      # login, garden_form, plan, alerts, scan, rescue
│       ├── services/     # api_client.dart, auth_service.dart, tflite_service.dart
│       └── widgets/
├── api/                  # Node.js Express backend (M1–M3)  ← my current focus
│   ├── src/
│   │   ├── server.js, routes/
│   │   ├── planner/      # recommend.js, layout.js, shoppingList.js, explain.js
│   │   ├── alerts/       # openMeteo.js, weatherRules.js, pestRisk.js
│   │   ├── rescue/       # steps.js
│   │   └── data/         # crops.json, diseases.json, pests.json (the KB)
│   ├── tests/            # jest + supertest per module
│   ├── package.json, Dockerfile, render.yaml
├── ml/                   # Python (M3): train_disease_model.ipynb (Colab),
│   └── export_tflite.py, evaluate.py, assets/labels.txt
├── seed/                 # seed_firestore.js (KB → Firestore, optional)
├── docs/                 # ARCHITECTURE.md, SETUP.md, DEMO_SCRIPT.md, diagrams
└── README.md
```

## 3. Knowledge base schemas (source of truth: JSON in `api/src/data/`)

**crops.json** — ~20 Kerala-terrace-friendly crops (tomato, chilli, brinjal, okra, snake gourd, ash gourd, pumpkin, cucumber, long bean, amaranthus/cheera, spinach, coriander, mint, curry leaf, ginger, turmeric, radish, beans, cabbage, cauliflower):
```json
{
  "id": "tomato", "nameEn": "Tomato", "nameMl": "തക്കാളി",
  "category": "fruit_veg", "difficulty": 2,
  "seasonMonths": [6,7,8,9,10,11,12], "daysToHarvest": [75,90],
  "minAreaSqFt": 2, "container": "grow bag / pot (≥12 in)",
  "sunlightHrs": [6,8], "waterPerDay": 1, "spacingCm": 45,
  "companion": ["basil","coriander"], "avoid": ["potato"],
  "commonPests": ["aphid","whitefly","fruit_borer"],
  "commonDiseases": ["early_blight","late_blight","leaf_curl"],
  "steps": [{"day":0,"title":"Sowing","body":"..."}, ...],
  "whyText": {"en":"Chosen because your terrace gets 6+ h sun...", "ml":"..."}
}
```

**diseases.json** — one entry per PlantVillage class actually trained: `id`, `nameEn`, `nameMl`, `crop`, `symptoms[]`, `causes`, `rescueSteps[]` (ordered, pedagogical: diagnose→isolate→treat(organic-first)→prevent→what-you-learned), `prevention[]`, `organicRemedies[]`.

**pests.json** — `id`, `nameEn/Ml`, `favoursCrops[]`, `riskWhen` (temp/humidity/rain ranges), `signs[]`, `control[]`.

## 4. Planner engine design (M1)

`POST /api/plan` → pipeline:
1. **Filter** KB by hard constraints: season (current month), sunlight hours, min area vs available area, space type (window → herbs/leafy only), user excludes.
2. **Rank** survivors by: beginner difficulty (weight .35), yield per sq ft (.25), season fit (.2), companion synergy with already-selected crops (.1), diversity bonus (.1).
3. **Select** top N to fill area (greedy knapsack on `minAreaSqFt`).
4. **Layout**: place on a grid (cells ≈ 1 sq ft); tall/trellis crops (beans, snake gourd) at the north/back edge, herbs front — returns `{cropId, cell}` positions.
5. **Explain**: every selected crop gets a `reason` string generated from the matched constraints (**the educational differentiator**).
6. **Shopping list**: aggregate seeds/seedlings, potting mix (L), containers, trellis, neem cake etc. with quantities + est. prices (₹).

Request/Response (contract):
```jsonc
// POST /api/plan
{ "spaceType": "terrace|balcony|window", "areaSqFt": 60,
  "sunlightHrs": 6, "orientation": "east|west|north|south",
  "location": {"lat":11.25,"lng":75.78}, "language":"en|ml",
  "experience":"beginner", "exclude":["brinjal"] }
// → 200
{ "planId":"...", "crops":[{"cropId":"tomato","nameEn":"Tomato","nameMl":"തക്കാളി",
    "reason":"6+ h direct sun matches tomato's 6–8 h need; Sep sowing suits Kerala's post-monsoon season…",
    "cells":[[3,1],[3,2]], "sowBy":"2026-09-30","harvestAround":"2026-12-15","waterPerDay":1}],
  "shoppingList":[{"item":"Tomato seeds","qty":"1 packet (≈50 seeds)","estPriceINR":30}, ...],
  "weeklyGuide":[ ... ], "generatedAt":"..." }
```

## 5. Alerts engine design (M2)

`GET /api/alerts?lat=..&lng=..&crops=tomato,okra&stageDays=21`
1. Fetch Open-Meteo: current + 7-day (temp max/min, humidity, precip prob/mm, wind).
2. **Weather rules** (severity info/warn/danger): rain ≥ 25 mm/day → "move pots / cover"; maxT ≥ 35 °C → heat stress + extra watering; minT ≤ 18 °C → slow growth; wind ≥ 40 km/h → secure trellis.
3. **Pest/disease risk model**: score each `pests.json.riskWhen` window against forecast (e.g., aphids: 20–28 °C + RH > 65 % → risk 0–1); multiply by crop susceptibility & stage; risk ≥ .6 → alert with signs-to-watch + organic control text.
4. Merge, sort by severity, translate (en/ml from KB), cache to Firestore `alerts` (dedupe by `type+cropId+date`).

```jsonc
// → 200
{ "weather": {"nowC":29.4,"humidity":81,"today":{"precipProb":80,"mm":18,"maxC":31,"minC":24}},
  "alerts": [
   {"type":"weather","severity":"warn","titleEn":"Heavy rain expected (80%, 18 mm)",
    "titleMl":"കനത്ത മഴയ്ക്ക് സാധ്യത","bodyEn":"Move seedlings under cover…","date":"2026-09-25"},
   {"type":"pest","severity":"warn","cropId":"tomato","risk":0.72,
    "titleEn":"Aphid risk rising (warm + humid)","bodyEn":"Check leaf undersides…",
    "controlEn":["neem oil 5 ml/L weekly","yellow sticky traps"]} ],
  "fetchedAt":"..." }
```

## 6. Rescue module design (M3)

- **Inference (on-device):** Flutter `tflite_flutter` + `image` pkg; model `plant_disease_mobilenet.tflite` (~10 MB), labels `ml/disease_labels.txt`; input 224×224 float; top-1 + confidence; if confidence < 0.55 → "unsure" path with general check-list (educational honesty).
- **Training (Colab, free GPU):** notebook downloads PlantVillage, MobileNetV2 (ImageNet weights, alpha 1.0), fine-tune 10 epochs, 80/10/10 split, target val-acc ≥ 90 %, export TFLite (float16 quantized).
- **Backend:** `POST /api/rescue-steps` `{ "diseaseId":"tomato___Early_blight","language":"ml" }` → ordered rescue steps + prevention + "what you learned" note; `POST /api/rescues` logs the case to Firestore (uid, imageUrl, prediction, confidence, steps shown, outcome) — powers future dashboard.

## 6b. Peer Pest Communication (MVP module ④ — added 23 Sep 2026)

**Concept.** Neighbour-to-neighbour pest intelligence: *"whitefly on tomato reported 2 km from you — 4 neighbours confirmed, neem oil 5 ml/L worked."* Bridges Module 3 (alerts) and Module 6 (community).

**Flow.**
1. **Publish** — after a rescue scan ("Warn neighbours?" prompt [D9]) or manually from the Community feed: crop, pest/disease (auto-filled from diagnosis if available), severity (low/med/high), note, optional photo (Firebase Storage), area name. Coords auto-rounded [D8].
2. **Match** — `GET /api/peer-alerts?lat&lng&crops=tomato,okra`: bounding-box prefilter (±0.05° ≈ 5 km) → haversine distance check → keep reports whose `cropId` ∈ requester's active-plan crops (or all, with `sameCropOnly=false`) → sort by (severity, recency, distance). Dedupe: max 1 report per user+pest+day.
3. **Consume** — Community Alert cards appear in the Alerts screen (distinct 📢 style, distance shown as "~2 km away") **and** in the Community feed.
4. **Discuss** — each report has a thread: replies (text + optional photo), "helpful" counter; original author gets a reply-count badge on their card. Bilingual UI strings (en/ml); message content is whatever language users type.
5. **Moderate** — any user can flag; `flagCount ≥ 3` → `status:"hidden"` (auto), visible to moderators only. Firestore rules: authenticated writes, author-only edit/delete.

**Data model (Firestore).**
```
pestReports/{rid}                → authorUid, authorName, cropId, pestId?, diseaseId?,
                                   lat2, lng2 (rounded), areaName?, severity:"low|med|high",
                                   note, photoUrl?, status:"visible|flagged|hidden",
                                   flagCount, repliesCount, helpfulCount, createdAt
pestReports/{rid}/messages/{mid} → authorUid, authorName, text, photoUrl?, helpfulCount, createdAt
```

**API additions (Express).**
```jsonc
POST /api/peer-alerts          // publish report (body as above; server rounds coords, validates against KB ids)
GET  /api/peer-alerts?lat&lng&radiusKm=5&crops=tomato&sameCropOnly=true
                               // → { reports: [ {..., distanceKm, topReplies:[…2] } ] }
POST /api/peer-alerts/:rid/messages   // reply to thread
POST /api/peer-alerts/:rid/flag       // moderation flag
```

**Why this design.** Zero extra infra (Firestore + existing API), demo-friendly with two accounts on two devices, and privacy-safe by construction. FCM push on new nearby reports and "Community Guardian" gamification points are post-MVP hooks (schema already supports them).

## 7. Firestore schema (user data; KB stays in repo)

```
users/{uid}                 → name, email, lang:"en|ml", points:0, badges:[], streak:{count,lastDate}, createdAt
users/{uid}/gardens/{gid}   → spaceType, areaSqFt, sunlightHrs, orientation, location{lat,lng}, photoUrl?, createdAt
users/{uid}/plans/{pid}     → gardenId, request{}, crops[], shoppingList[], generatedAt, status:"active|done"
users/{uid}/alerts/{aid}    → type, severity, titleEn/Ml, bodyEn/Ml, cropId?, risk?, date, read:false
users/{uid}/rescues/{rid}   → gardenId, imageUrl, diseaseId, confidence, stepsShown[], outcome?, createdAt
pestReports/{rid} (+ /messages/{mid}) → see §6b (public collection, auth-write)
```
Security rules: user-scoped read/write (`request.auth.uid == userId`); `pestReports` readable by any authenticated user, writable only by its author (moderation fields writable per flag logic).

## 8. Flutter demo shell (M4 + M4.5) — 8 screens

`Login` (Firebase Auth email+Google) → `Home` → `Garden Form` (space profile + photo to Storage) → `Plan` (calls `/api/plan`; crop cards with reasons, layout grid, shopping list) → `Alerts` (calls `/api/alerts` **and** `/api/peer-alerts`; severity-colored cards + 📢 community cards, en/ml toggle) → `Scan & Rescue` (camera → TFLite → `/api/rescue-steps`; step-by-step UI; ends with **"Warn neighbours?"** prompt) → `Community Feed` (nearby pest reports, publish button, thread view with replies + helpful/flag). Stubs: `Dashboard`, `Marketplace` ("coming soon").

## 9. Testing & demo strategy

- API: jest + supertest unit tests per module; golden tests for planner (fixed input → expected crops/reasons); live test with Kozhikode coords (11.2588, 75.7804).
- ML: val accuracy + confusion matrix in notebook; 5 real-leaf sanity photos.
- Peer loop: jest tests for haversine/bounding-box matching & dedupe; manual E2E with **2 accounts on 2 devices** (reporter → neighbour sees alert → replies → flag path).
- E2E demo script (`docs/DEMO_SCRIPT.md`): wake Render API → login → create garden → plan → alerts → scan diseased leaf → rescue steps → **"Warn neighbours" → second account sees community alert & replies**. Include offline fallback (recorded video) for review day.

## 10. Open items for the team

1. Confirm/adjust **[D1]–[D6]** decisions above.
2. Create GitHub repo + Firebase project (I'll give exact steps in M0 SETUP.md).
3. Assign the 4 role slots (PLAN.md §5).
4. Crop KB: confirm the 20-crop list & add any local favourites (e.g., tapioca, betel leaf?).
5. Peer pest loop: confirm 5 km default radius & the "Warn neighbours" auto-prompt; **add this feature to your next review slides** (it visibly strengthens Modules 3 & 6 and adds a fresh "community intelligence" angle reviewers like).
