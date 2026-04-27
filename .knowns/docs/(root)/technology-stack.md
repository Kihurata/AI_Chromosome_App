---
title: Technology Stack
description: Technology stack overview for Frontend, Backend, and Infrastructure.
createdAt: '2026-04-26T07:07:42.022Z'
updatedAt: '2026-04-26T07:07:42.022Z'
tags:
  - tech-stack
  - flutter
  - fastapi
  - firebase
---

# Technology Stack
The AI Chromosome Karyotyping App is a Monorepo containing:

## Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management (Hybrid)**:
  - **Riverpod**: Used as a "Data Pipe" for streaming real-time data from Firestore.
  - **Cubit (BLoC)**: Used as a "UI Controller" for managing local drag-and-drop interactions in the workspace.
- **Architecture**: Flutter Clean Architecture (Presentation, Logic, Data, Core).

## Backend (FastAPI)
- **Framework**: FastAPI (Python 3.9+)
- **Integration**: Firebase Admin SDK for centralized data management and proxying to the AI Server.
- **AI Processing**: Segmentation/Classification models using OpenCV and PyTorch/TensorFlow.

## Infrastructure & Database
- **Platform**: Firebase
- **Services**: Authentication, Firestore (NoSQL), Cloud Storage.
