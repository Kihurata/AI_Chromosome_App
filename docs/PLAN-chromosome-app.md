# Chromosome Karyotyping App - Project Plan

## Overview
A medical application for doctors to analyze Metaphase images, perform karyotyping through a drag-and-drop workspace, and generate ISCN standard reports. Created as a school assignment, emphasizing parallel development and real-time state synchronization.

## Project Type
**DESKTOP & MOBILE** (Flutter - Desktop for main app, Mobile for QR Scanner) + **BACKEND** (FastAPI) + **AI** (Python/Segmentation)

## Success Criteria
- Doctors can upload Metaphase images and view AI results.
- Karyotyping Workspace supports real-time drag-and-drop and rotation using Firebase listeners.
- API requests securely route through FastAPI Gateway to the local Ngrok AI server.
- The 3 teams (Frontend, Backend, AI) can work in parallel using JSON mock data.

## Tech Stack
### Frontend (Desktop & Mobile)
- **Framework:** Flutter (Desktop build for the Karyotyping Workspace, Mobile build exclusively for QR Scanning)
- **State/Real-time:** Firebase SDK (Firestore listeners for real-time syncing)

### Backend (API Gateway & DB)
- **Framework:** FastAPI (Python)
- **Database:** Firebase Authentication, Firestore (Metadata, Logs), Firebase Storage (Images)
- **Role:** Secures traffic, proxies AI requests, logs audit trails.

### AI Engine (External Processing)
- **Models:** Segmentation (splitting individual chromosomes) & Classification (detecting chromosome pairs)
- **Hosting:** Hosted externally on Google Colab or similar cloud infrastructure, exposed via Ngrok for the FastAPI Backend to communicate with.

## File Structure
```text
/
├── frontend/               # Flutter application
│   ├── lib/
│   │   ├── screens/        # Lightbox, Workspace, Report
│   │   ├── services/       # Firebase, API clients
│   │   └── models/         # Mock data JSONs, Object models
│   └── pubspec.yaml
├── backend/                # FastAPI Gateway
│   ├── app/
│   │   ├── api/            # Routes (Auth, proxy to AI)
│   │   └── core/           # Firebase Admin SDK setup
│   └── requirements.txt
# Note: The AI Engine runs entirely externally (e.g. Google Colab + Ngrok).
# It is NOT bundled inside the app. The FastAPI Backend connects to the external Ngrok URL.
└── ai_scripts/             # External scripts for Colab
    └── colab_server.ipynb  # Script to host AI securely via Ngrok
```

## Task Breakdown (Parallel Development)

### Phase 1: Parallel Foundation & Mocks

#### Task 1: Initialize Frontend & Mock State
**Agent:** `mobile-developer` | **Skill:** `mobile-design`
- **Dependencies:** None
- **INPUT:** Clean Flutter project.
- **OUTPUT:** Flutter app with basic routing and mock JSON data for the Workspace.
- **VERIFY:** App runs locally, doctor can view fake Karyogram data on screen.

#### Task 2: Build FastAPI Gateway Foundation
**Agent:** `backend-specialist` | **Skill:** `api-patterns`
- **Dependencies:** None
- **INPUT:** Clean Python environment.
- **OUTPUT:** FastAPI server connected to Firebase Admin SDK with a `POST /analyze` dummy endpoint.
- **VERIFY:** HTTP request to the dummy endpoint returns 200 OK.

#### Task 3: Setup AI Segmentation API
**Agent:** `backend-specialist` (AI role) | **Skill:** `python-patterns`
- **Dependencies:** None
- **INPUT:** Local Python environment.
- **OUTPUT:** Python server exposing endpoints for image ingestion and returning bounding boxes / classifications.
- **VERIFY:** Sending a sample Metaphase image to local AI endpoint returns proper JSON format.

### Phase 2: Core Features (Concurrent)

#### Task 4: Frontend Desktop Workspace Drag & Drop
**Agent:** `mobile-developer` | **Skill:** `mobile-design`
- **Dependencies:** Task 1
- **INPUT:** Mock JSON data.
- **OUTPUT:** Interactive UI where chromosomes can be dragged, rotated, and flipped. UI syncs to Firebase listeners.
- **VERIFY:** Dragging an item updates Firestore; changes instantly reflect on the screen.

#### Task 5: Backend Proxy & Audit Implementation
**Agent:** `backend-specialist` | **Skill:** `database-design`
- **Dependencies:** Task 2
- **INPUT:** FastAPI server.
- **OUTPUT:** Logic that receives image from Frontend, authenticates user, forwards to Ngrok URL, and logs the `AuditLogs` in Firestore.
- **VERIFY:** End-to-end test of the proxy route correctly logging in Firebase before responding.

#### Task 6: AI Model Integration
**Agent:** `backend-specialist` (AI Role) | **Skill:** `python-patterns`
- **Dependencies:** Task 3
- **INPUT:** Bare AI API.
- **OUTPUT:** Integration of actual trained segmentation/classification models into the API endpoints.
- **VERIFY:** API correctly outputs number of chromosomes (e.g., 46 or 47 for Down syndrome).

### Phase 3: Integration & Reporting

#### Task 7: Full System Integration
**Agent:** `orchestrator` | **Skill:** `parallel-agents`
- **Dependencies:** Task 4, 5, 6
- **INPUT:** All three environments running.
- **OUTPUT:** Frontend points to FastAPI, FastAPI points to AI Ngrok. Complete data flow from upload to Karyogram workspace.
- **VERIFY:** Uploading an image in Flutter successfully runs through the whole pipeline and shows up in the Workspace.

#### Task 8: PDF Report Generation
**Agent:** `backend-specialist` | **Skill:** `api-patterns`
- **Dependencies:** Task 7
- **INPUT:** Final confirmed Karyogram data.
- **OUTPUT:** FastAPI endpoint to generate ISCN standard PDF report.
- **VERIFY:** PDF downloaded contains correct ISCN string (e.g., `47,XY,+21`) and image snippet.

## ✅ Phase X: Final Verification
- [ ] **Lint:** Flutter format & Python flake8/black executed.
- [ ] **Security Scan:** Verify Firebase Rules restrict unauthorized access to `Patient` and `AuditLog` data.
- [ ] **Data Flow:** Run E2E test to upload image and view segmented results.
- [ ] **Socratic Gate:** Was Socratic gate respected prior to code implementation? (Yes)
