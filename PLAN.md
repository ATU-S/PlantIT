# PlantIT — Project Plan

> **Project:** PlantIT — An Intelligent Urban Farming Companion
> **Team:** Group 11, Dept. of CSE, KMCT College of Engineering — Ananthu S, Shahla K, Ujjwal S R, Hina Jan K R
> **Guide:** Dr. Kavitha S Murugeshan
> **Status:** ✅ Phase A (Clarify) complete · ✅ Phase B (Design) complete → see `DESIGN.md` · **Next: Phase C (Scaffold) — awaiting GO**

---

## 1. Confirmed decisions (Phase A answers — 23 Sep 2026)

| Question | Answer |
|----------|--------|
| Codebase status | **Nothing started** — build from scratch |
| Target milestone | **Working MVP ASAP** (no fixed college date) |
| My focus | **Backend & integrations** (Node.js API, Firebase, weather API, AI wiring; Flutter demo shell comes after) |
| MVP scope | **Core 3 modules**: ① AI Farm Planning (+ Smart Shopping List output) ② Weather & Pest Alerts ③ Crop Failure Rescue. Modules 5–6 (Gamification, Marketplace) + Voice = **stubbed / post-MVP** |

## 2. What "MVP done" means (demo acceptance criteria)

1. Given a space profile (type, size, sunlight, location), the API returns **crop suggestions + layout + reasons + shopping list** (English & Malayalam names).
2. Given coordinates (e.g., Kozhikode), the API returns **current weather + hyperlocal risk alerts** (heavy rain / heat stress) and **crop-specific pest/disease risk warnings** computed from weather rules.
3. Given a leaf photo, the on-device **TFLite model classifies the disease**, and the API returns **step-by-step recovery guidance** (pedagogical rescue).
4. A **thin Flutter demo app** (auth + 3 screens) exercises all three flows end-to-end for the demo.
5. Firestore stores users, gardens, plans, alerts, rescues; repo has README + setup guide + demo script.

## 3. Milestone roadmap (ASAP track, starting 23 Sep 2026)

| Milestone | Window | Deliverables | Who |
|-----------|--------|--------------|-----|
| **M0 — Setup** | Sep 23–24 | GitHub repo + folder skeleton, Firebase project (free Spark tier), Flutter app created locally, toolchain verified | Team (I provide step-by-step) |
| **M1 — Planner backend** | Sep 24–27 | Crop knowledge base (JSON, ~20 Kerala-friendly crops), recommendation engine with explanations, shopping-list generator, `POST /api/plan`, seed script; tested via curl/Postman | Me (code) + backend pair |
| **M2 — Alerts backend** | Sep 28–30 | Open-Meteo integration (no API key), weather alert rules, pest/disease risk engine per crop stage, `GET /api/alerts`; tested with real Kozhikode coordinates | Me + backend pair |
| **M3 — Rescue ML** | Oct 1–7 (parallel from Oct 1) | Colab notebook: MobileNetV2 transfer learning on PlantVillage (~38 classes), TFLite export, accuracy report; recovery-steps KB + `POST /api/rescue-steps`; Flutter `tflite_flutter` integration snippet | ML pair runs notebook; I write code/docs |
| **M4 — Demo shell app** | Oct 8–14 | Minimal Flutter app: Firebase Auth, Garden form → Plan screen, Alerts screen, Leaf-scan → Rescue screen; deploy API to Render free tier | App pair; I write code |
| **M5 — Polish & docs** | Oct 15–21 | README, setup guide, demo script, architecture diagrams for next review, stub screens for Gamification/Marketplace, backlog for Voice (ml/en) | All |

**Post-MVP backlog (not in scope now):** Malayalam/English voice (speech_to_text + flutter_tts, ml-IN), Gamification & Green Impact Dashboard, Community/Nursery Marketplace, Gemini-Vision space-photo analysis upgrade, scheduled push notifications.

## 4. Kanban backlog (initial)

**TO DO**
- [ ] T1 GitHub org/repo `plantit` + branch protection (M0)
- [ ] T2 Firebase project + Auth + Firestore + Storage, download `google-services.json` (M0)
- [ ] T3 Flutter app scaffold `plantit_app` (M0)
- [ ] T4 Crop KB JSON: 20 crops with en/ml names, season, spacing, sun/water needs, pests, diseases, steps (M1)
- [ ] T5 Planner engine: filter + rank + explain + layout grid + shopping list (M1)
- [ ] T6 Express API skeleton + `/api/plan`, `/api/crops` (M1)
- [ ] T7 Open-Meteo client + weather alert rules (M2)
- [ ] T8 Pest/disease risk rule engine (temp/humidity/rain × crop stage) (M2)
- [ ] T9 `/api/alerts` endpoint + Firestore caching of alerts (M2)
- [ ] T10 Colab training notebook + TFLite export (M3)
- [ ] T11 Disease KB + recovery steps + `/api/rescue-steps` (M3)
- [ ] T12 Flutter leaf-scan screen with tflite_flutter (M3/M4)
- [ ] T13 Flutter 3-screen demo shell + Auth (M4)
- [ ] T14 Deploy API to Render (M4)
- [ ] T15 README + SETUP.md + DEMO_SCRIPT.md (M5)

**IN PROGRESS** — *(empty — say GO to start T4–T6 immediately; T1–T3 need the team's accounts/devices)*

**DONE**
- [x] Read abstract + Zeroth Review deck
- [x] Phase A clarify (4 questions answered)
- [x] Phase B design → `DESIGN.md`

## 5. Division of labour

| Role | Tasks | Person(s) |
|------|-------|-----------|
| **Me (Qwen)** | All backend/ML/Flutter code, KB content, notebooks, docs, configs in this workspace | — |
| **Backend pair** | Runs/tests API locally, Render deploy, Firebase console | suggest: Ananthu / Ujjwal |
| **ML pair** | Runs Colab notebook (free GPU), reports accuracy, tests TFLite on device | suggest: Hina |
| **App pair** | Android Studio, runs Flutter app on device, Firebase wiring | suggest: Shahla |
| *(Team re-assigns as needed — I can't run an Android emulator or access your Firebase/Google accounts from here.)* | | |

## 6. Key risks & mitigations

| Risk | Mitigation |
|------|------------|
| Firebase **Cloud Functions need Blaze (paid) plan** | MVP backend = plain Node/Express on **Render free tier**; Firestore still on free Spark plan. (Design keeps logic portable to Functions later.) |
| Render free tier sleeps after idle | Cold start ~30 s on first request; note in demo script ("wake the API before presenting"). |
| PlantVillage lab images ≠ real terrace-garden leaves | Set demo expectations; collect a few real local leaf photos for fine-tuning post-MVP. |
| Malayalam text/fonts in JSON KB | Store Unicode ml names in KB from day 1; app uses Noto Sans Malayalam (Android default). |
| No emulator in my sandbox | Every slice ships with exact run/test commands for the team. |

## 7. Log

- **2026-09-23** — Plan skeleton created.
- **2026-09-23** — Read `uploads/PlantIT.pdf` + `uploads/PlantIT_Zeroth_Review.pdf`; Section 1 filled.
- **2026-09-23** — Phase A answers received (scratch / ASAP / backend-first / core-3). Phase B design written to `DESIGN.md`. Roadmap M0–M5 + Kanban backlog added. **Awaiting GO for Phase C.**
