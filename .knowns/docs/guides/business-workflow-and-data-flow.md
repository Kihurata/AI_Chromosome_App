---
title: Business Workflow and Data Flow
description: Detailed breakdown of the 6-stage workflow, user roles, state transitions, and exception handling.
createdAt: '2026-04-26T07:07:49.572Z'
updatedAt: '2026-04-26T07:07:49.572Z'
tags:
  - workflow
  - dataflow
  - roles
  - business-logic
---

# Business Workflow and Data Flow
The AI Chromosome App revolves around a 6-stage workflow coordinating four main roles: Receptionist, Clinician, Manager, and Specialist.

## Roles & Responsibilities
1. **Receptionist**: Creates patient profiles and schedules appointments. Assigns patients to clinicians.
2. **Clinician**: Conducts examinations, creates genetic test orders, collects physical samples (labeled with QR codes), and transfers them to the Lab.
3. **Manager (Lab)**: Receives orders/samples, assigns them to Specialists, and approves the final Karyotyping results.
4. **Specialist**: Handles lab procedures (culturing, harvesting), utilizes AI tools for Karyotyping, finalizes the ISCN formula, and submits for approval.

## Status Transitions
- **Appointments**: `scheduled` -> `completed`
- **Samples**: `COLLECTED` -> `CULTURING` -> `HARVESTED` (or `FAILED`)
- **Test Orders**: `WAIT_ASSIGN` -> `CULTURING` -> `ANALYZING` -> `PENDING_APPROVAL` -> `COMPLETED`

## Automated State Management (Cloud Functions)
- **Assign Specialist**: `test_orders` -> `CULTURING`
- **Start Culturing**: `samples.status = CULTURING` -> `test_orders` -> `CULTURING`
- **AI Counting/Imaging**: `metaphase_images` updated -> `test_orders` -> `ANALYZING`
- **Specialist Submit**: `test_orders` -> `PENDING_APPROVAL`
- **Manager Approve**: `test_orders` -> `COMPLETED` (Generates PDF report)

## Exception Handling
- **Failed Culture**: If a sample fails, the system alerts the Clinician to recollect. The order is suspended until a new sample is provided.
- **Approval Rejection**: If the Manager rejects, the order reverts to `ANALYZING` for the Specialist to correct.

## Workflow Diagram
```mermaid
graph TD
    R[Receptionist]
    C[Clinician]
    M[Manager]
    S[Specialist]

    Start((Patient Arrives)) --> R
    R -- "1. Create Profile/Appt" --> C
    R -- "Assign Doctor" --> C
    
    C -- "2. Examine & Create Orders/Samples" --> M
    C -- "Physical Transfer: Samples" --> M
    
    M -- "3. Assign Specialist" --> S
    
    S -- "4. Lab Processing & AI Analysis" --> S
    S -- "Status: PENDING" --> M
    
    M -- "5. Approve Results" --> C
    C -- "6. Notify Patient" --> End((Completed))
```
